require 'danconia/errors/api_error'
require 'net/http'
require 'json'

module Danconia
  module Exchanges
    # Fetches the rates from https://currencylayer.com/. The `access_key` must be provided.
    # See `examples/currency_layer.rb` for a complete usage example.
    class CurrencyLayer < Exchange
      attr_reader :store

      def initialize access_key:, store: Stores::InMemory.new
        @access_key = access_key
        @store = store
      end

      def fetch_rates
        response = JSON.parse Net::HTTP.get URI "http://www.apilayer.net/api/live?access_key=#{@access_key}"
        if response['success']
          response['quotes']
        else
          raise Errors::APIError, response
        end
      end

      def update_rates!
        @store.save_rates fetch_rates.map { |pair, rate| {pair: pair, rate: rate} }
      end

      def rates **_opts
        array_of_rates_to_hash @store.rates
      end
    end
  end
end
