require 'bigdecimal'
require 'danconia/errors/exchange_rate_not_found'

module Danconia
  class Money
    include Comparable
    attr_reader :amount, :currency, :decimals, :exchange

    def initialize amount, currency_code = nil, decimals: 2, exchange: Danconia.config.default_exchange
      @decimals = decimals
      @amount = parse amount
      @currency = Currency.find(currency_code || Danconia.config.default_currency, exchange)
      @exchange = exchange
    end

    def to_s
      ActiveSupport::NumberHelper.number_to_currency amount, precision: decimals, unit: currency.symbol
    end

    def inspect
      "#{amount} #{currency.code}"
    end

    def == other
      if other.is_a?(Money)
        amount == other.amount && currency == other.currency
      else
        amount == other && currency.code == Danconia.config.default_currency
      end
    end

    def eql? other
      self == other
    end

    def hash
      [amount, currency].hash
    end

    def <=> other
      other = other.exchange_to(currency).amount if other.is_a? Money
      amount <=> other
    end

    def exchange_to other_currency
      other_currency = other_currency.presence && Currency.find(other_currency, exchange) || currency
      rate = exchange_rate_to(other_currency.code)
      clone_with amount * rate, other_currency
    end

    def exchange_rate_to to
      from = currency.code
      return 1 if from == to
      exchange.rate from, to
    end

    %w(+ - * /).each do |op|
      class_eval <<-EOR, __FILE__, __LINE__ + 1
        def #{op} other
          other = other.exchange_to(currency).amount if other.is_a? Money
          clone_with amount #{op} other
        end
      EOR
    end

    def round *args
      clone_with amount.round(*args)
    end

    def in_cents
      (self * 100).round
    end

    def default_currency?
      currency.code == Danconia.config.default_currency
    end

    def method_missing method, *args
      if @amount.respond_to? method
        @amount.send method, *args
      else
        super
      end
    end

    def respond_to? method, *args
      super or @amount.respond_to?(method, *args)
    end

    private

    def parse object
      BigDecimal(object&.to_s)
    end

    def clone_with amount, currency = @currency
      Money.new amount, currency, decimals: decimals, exchange: exchange
    end
  end
end
