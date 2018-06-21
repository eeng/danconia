module Danconia
  class << self
    def config
      @config ||= Config.new
    end

    def config= c
      @config = c
    end
  end

  class Config
    attr_accessor :default_currency, :available_currencies, :get_exchange_rate

    def initialize
      @default_currency = 'USD'
      @available_currencies = []
      @get_exchange_rate = -> src, dst { nil }
    end
  end
end
