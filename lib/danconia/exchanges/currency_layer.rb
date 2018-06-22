require 'danconia/errors/api_error'
require 'net/http'
require 'json'

module Danconia
  module Exchanges
    class CurrencyLayer < Exchange
      def initialize access_key:, **args
        super args
        @access_key = access_key
      end

      def update_rates!
        @store.save_rates fetch_rates
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
