module Danconia
  module Stores
    class InMemory
      def save_rates rates
        @rates = rates
      end

      def rates **filters
        @rates.select do |r|
          filters.all? { |k, v| r[k] == v }
        end
      end
    end
  end
end
