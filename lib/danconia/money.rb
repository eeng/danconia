require 'bigdecimal'
require 'danconia/errors/exchange_rate_not_found'
require 'danconia/serializable'

module Danconia
  class Money
    include Comparable
    include Serializable
    attr_reader :amount, :currency, :decimals

    def initialize(amount, currency_code = nil, decimals: 2, exchange_opts: {})
      @amount = parse amount
      @decimals = decimals
      @currency = Currency.find(currency_code || Danconia.config.default_currency)
      @exchange_opts = exchange_opts.reverse_merge(exchange: Danconia.config.default_exchange)
    end

    def format decimals: @decimals, **other_options
      opts = other_options.reverse_merge precision: decimals, unit: currency.symbol
      ActiveSupport::NumberHelper.number_to_currency amount, opts
    end

    alias to_s format

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
      amount <=> amount_exchanged_to_this_currency(other)
    end

    def exchange_to other_currency, **opts
      opts = @exchange_opts.merge(opts)
      other_currency = other_currency.presence && Currency.find(other_currency) || currency
      rate = opts[:exchange].rate currency.code, other_currency.code, opts.except(:exchange)
      clone_with amount * rate, other_currency, opts
    end

    %w[+ - * /].each do |op|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{op} other
          clone_with(amount #{op} amount_exchanged_to_this_currency(other))
        end
      RUBY
    end

    def round *args
      clone_with amount.round(*args)
    end

    def in_cents
      (self * 100).round
    end

    def as_json *args
      amount.as_json *args
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
      BigDecimal(object.to_s) rescue BigDecimal(0)
    end

    def clone_with amount, currency = @currency, exchange_opts = @exchange_opts
      Money.new amount, currency, decimals: @decimals, exchange_opts: exchange_opts
    end

    def amount_exchanged_to_this_currency other
      if other.is_a? Money
        other.exchange_to(currency, @exchange_opts).amount
      else
        other
      end
    end
  end
end
