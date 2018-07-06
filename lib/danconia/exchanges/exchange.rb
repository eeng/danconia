module Danconia
  module Exchanges
    class Exchange
      attr_reader :store

      def initialize store: Stores::InMemory.new
        @store = store
      end

      def rate from, to
        if from == 'USD' and direct_rate = @store.direct_rate(from, to)
          direct_rate
        elsif to == 'USD' and inverse_rate = @store.direct_rate(to, from)
          (1.0 / inverse_rate).round 6
        elsif from != 'USD' and to != 'USD' and from_in_usd = rate(from, 'USD') and to_per_usd = rate('USD', to)
          (from_in_usd * to_per_usd).round 6
        else
          raise Errors::ExchangeRateNotFound.new(from, to)
        end
      end

      def rates
        @store.rates
      end

      def update_rates!
        @store.save_rates fetch_rates
      end
    end
  end
end