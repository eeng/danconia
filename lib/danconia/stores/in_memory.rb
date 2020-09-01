module Danconia
  module Stores
    class InMemory
      attr_reader :rates

      def save_rates rates
        @rates = rates
      end
    end
  end
end
