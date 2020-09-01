module Danconia
  module Exchanges
    class FixedRates < Exchange
      def initialize rates: {}
        @rates = rates
      end

      def rates _opts
        @rates
      end
    end
  end
end
