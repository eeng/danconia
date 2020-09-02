require 'danconia/errors/api_error'
require 'danconia/stores/in_memory'
require 'net/http'
require 'json'

module Danconia
  module Exchanges
    class CurrencyLayer < Exchange
      def initialize access_key:, store: Stores::InMemory.new
        @access_key = access_key
        @store = store
      end

      def rates **_opts
        Hash[@store.rates.map { |er| er.values_at(:pair, :rate) }]
      end

      def update_rates!
        @store.save_rates fetch_rates.map { |pair, rate| {pair: pair, rate: rate} }
      end

      def fetch_rates
        response = JSON.parse Net::HTTP.get URI "http://www.apilayer.net/api/live?access_key=#{@access_key}"
        if response['success']
          response['quotes']
        else
          raise Errors::APIError, response
        end
      end
    end
  end
end
