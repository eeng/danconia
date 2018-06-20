module ActsAsMoney
  class << self
    def config
      @config ||= Config.new
    end

    def config= c
      @config = c
    end
  end

  class Config
    attr_accessor :default_currency, :available_currencies

    def initialize
      @default_currency = 'USD'
      @available_currencies = []
    end
  end
end
