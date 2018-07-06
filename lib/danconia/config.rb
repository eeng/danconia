module Danconia
  class << self
    def config
      @config ||= Config.new
    end

    def config= c
      @config = c
    end

    def configure
      yield config
    end
  end

  class Config
    attr_accessor :default_currency, :default_exchange, :available_currencies

    def initialize
      @default_currency = 'USD'
      @default_exchange = Exchanges::FixedRates.new
      @available_currencies = []
    end
  end
end
