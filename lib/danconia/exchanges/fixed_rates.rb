module Danconia
  module Exchanges
    class FixedRates < Exchange
      def initialize rates: {}, **args
        super args
        @store.save_rates rates
      end
    end
  end
end
