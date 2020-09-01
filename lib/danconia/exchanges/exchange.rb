module Danconia
  module Exchanges
    class Exchange
      attr_reader :store

      def initialize store: Stores::InMemory.new
        @store = store
      end

      def rate from, to
        if from == to
          1.0
        elsif from == 'USD' and direct_rate = @store.direct_rate(from, to)
          direct_rate
        elsif to == 'USD' and inverse_rate = @store.direct_rate(to, from)
          1.0 / inverse_rate
        elsif from != 'USD' and to != 'USD' and from_in_usd = rate(from, 'USD') and to_per_usd = rate('USD', to)
          from_in_usd * to_per_usd
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
