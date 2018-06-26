module Danconia
  module TestHelpers
    class << self
      def with_config &block
        old_config = Danconia.config.dup
        Danconia.configure &block
        Danconia.config = old_config
      end

      def with_rates rates
        with_config do |config|
          config.default_exchange = Exchanges::FixedRates.new rates: rates, currencies: config.default_exchange.currencies
          yield
        end
      end
    end
  end
end