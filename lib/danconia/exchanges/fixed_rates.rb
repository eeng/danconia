module Danconia
  module Exchanges
    class FixedRates < Exchange
      def initialize rates: {}
        super()
        @store.save_rates rates
      end
    end
  end
end
