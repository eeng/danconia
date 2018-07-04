module Danconia
  module Exchanges
    class FixedRates < Exchange
      def initialize rates: {}, **args
        super args
        @rates = rates
        update_rates!
      end

      def fetch_rates
        @rates
      end
    end
  end
end
