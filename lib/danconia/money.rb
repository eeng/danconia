require 'delegate'
require 'bigdecimal'
require 'danconia/errors/exchange_rate_not_found'

module Danconia
  class Money < DelegateClass(BigDecimal)
    attr_reader :decimals, :currency
    alias :amount :__getobj__

    def initialize amount, currency_code = Danconia.config.default_currency, decimals: 2
      @decimals = decimals
      @currency = Currency[currency_code]
      super parse(amount).round(@decimals)
    end

    %w(+ - * /).each do |op|
      class_eval %Q{
        def #{op} other
          other = parse other
          Money.new super, decimals: decimals
        end
      }
    end

    def to_s
      "#{currency.symbol}%.#{decimals}f" % amount
    end

    def inspect
      "#<#{self.class.name} amount: #{amount} currency: #{currency.code} decimals: #{decimals}>"
    end

    def in_cents
      (self * 100).round
    end

    def exchange_to other_currency
      rate = Danconia.config.get_exchange_rate.call(@currency.code, other_currency) or raise Errors::ExchangeRateNotFound.new(@currency.code, other_currency)
      Money.new amount * rate, other_currency
    end

    private

    def parse object
      return object if object.is_a? Money
      BigDecimal(object.to_s) rescue BigDecimal('0')
    end
  end
end
