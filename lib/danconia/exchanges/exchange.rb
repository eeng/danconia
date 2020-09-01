require 'danconia/pair'

module Danconia
  module Exchanges
    class Exchange
      attr_reader :store

      def initialize store: Stores::InMemory.new
        @store = store
      end

      def rate from, to
        return 1.0 if from == to

        pair = Pair.new(from, to)
        rates = direct_and_inverted_rates()
        rates[pair] or indirect_rate(pair, rates) or raise Errors::ExchangeRateNotFound.new(from, to)
      end

      def rates
        @store.rates
      end

      def update_rates!
        @store.save_rates fetch_rates
      end

      private

      # Returns the original rates plus the inverted ones, to simplify rate finding logic.
      def direct_and_inverted_rates
        rates.each_with_object({}) do |(pair_str, rate), rs|
          pair = Pair.parse(pair_str)
          rs[pair] = rate
          rs[pair.invert] ||= 1.0 / rate
        end
      end

      def indirect_rate ind_pair, rates
        if (from_pair = rates.keys.detect { |(pair, rate)| pair.from == ind_pair.from }) &&
           (to_pair = rates.keys.detect { |(pair, rate)| pair.to == ind_pair.to })
          rates[from_pair] * rates[to_pair]
        end
      end
    end
  end
end
