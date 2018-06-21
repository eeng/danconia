require 'delegate'
require 'bigdecimal'
require 'danconia/errors/exchange_rate_not_found'

module Danconia
  class Money < DelegateClass(BigDecimal)
    include Comparable

    attr_reader :decimals, :currency
    alias :amount :__getobj__

    def initialize amount, currency_code = Danconia.config.default_currency, decimals: 2
      @decimals = decimals
      @currency = Currency[currency_code]
      super parse(amount).round(@decimals)
    end

    %w(+ - * /).each do |op|
      class_eval <<-EOR, __FILE__, __LINE__ + 1
        def #{op} other
          other = other.exchange_to(currency).amount if other.is_a? Money
          new_with_same_opts amount #{op} other, currency
        end
      EOR
    end

    def to_s
      ActiveSupport::NumberHelper.number_to_currency amount, precision: decimals, unit: currency.symbol
    end

    def inspect
      "#<#{self.class.name} amount: #{amount}, currency: #{currency.code}, decimals: #{decimals}>"
    end

    def == other
      if other.is_a?(Money)
        amount == other.amount && currency == other.currency
      else
        amount == other && currency.code == Danconia.config.default_currency
      end
    end

    def hash
      [amount, currency].hash
    end

    def <=> other
      other = other.exchange_to(currency).amount if other.is_a? Money
      amount <=> other
    end

    def exchange_to other_currency
      other_currency = Currency[other_currency]
      if rate = get_exchange_rate(currency, other_currency)
        new_with_same_opts amount * rate, other_currency
      else
        raise Errors::ExchangeRateNotFound.new(@currency.code, other_currency.code)
      end
    end

    def in_cents
      (self * 100).round
    end

    private

    def parse object
      BigDecimal(object.to_s) rescue BigDecimal('0')
    end

    def get_exchange_rate from, to
      if from == to
        1
      else
        Danconia.config.get_exchange_rate.call(from.code, to.code)
      end
    end

    def new_with_same_opts amount, currency
      Money.new amount, currency, decimals: decimals
    end
  end
end
