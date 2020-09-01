module Danconia
  module Stores
    class InMemory
      attr_reader :rates

      # `rates` should be of a map of pair->rate like {'USDEUR' => 1.25}
      def initialize rates: {}
        save_rates rates
      end

      def save_rates rates
        @rates = rates
      end
    end
  end
end
