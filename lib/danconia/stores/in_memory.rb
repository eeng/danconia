module Danconia
  module Stores
    class InMemory
      attr_reader :rates

      def initialize rates: {}
        save_rates rates
      end

      # @rates should be of a map of pair->rate like {'USDEUR' => 1.25}
      def save_rates rates
        @rates = rates
      end

      def direct_rate from, to
        @rates[[from, to].join]
      end
    end
  end
end
