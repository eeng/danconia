module Danconia
  module Stores
    class InMemory
      def save_rates rates
        @rates = rates
      end

      def rates **_opts
        @rates
      end
    end
  end
end
