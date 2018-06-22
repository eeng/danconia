require 'danconia/exchange'

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
    attr_accessor :default_currency, :default_exchange

    def initialize
      @default_currency = 'USD'
      @default_exchange = Exchange.new
    end
  end
end
