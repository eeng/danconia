require 'danconia/errors/api_error'
require 'net/http'
require 'json'

module Danconia
  module Exchanges
    class CurrencyLayer < Exchange
      def initialize access_key:
        @access_key = access_key
      end

      def rate from, to
        if from == 'USD' and direct = ExchangeRate.find_by(from: from, to: to)
          direct.rate
        elsif to == 'USD' and inverse = ExchangeRate.find_by(from: to, to: from)
          1 / inverse.rate
        elsif from != 'USD' and to != 'USD' and from_in_usd = rate(from, 'USD') and to_per_usd = rate('USD', to)
          from_in_usd * to_per_usd
        end
      end

      def update_rates!
        store_rates fetch_rates
      end

      def fetch_rates
        response = JSON.parse Net::HTTP.get URI "http://www.apilayer.net/api/live?access_key=#{@access_key}"
        if response['success']
          response['quotes'].map do |pair, quote|
            from, to = pair[0,3], pair[3,3]
            {from: from, to: to, rate: quote}
          end
        else
          raise Errors::APIError, response
        end
      end

      def store_rates rates
        rates.each do |rate|
          ExchangeRate.where(from: rate[:from], to: rate[:to]).first_or_initialize.update rate: rate[:rate]
        end
      end
    end
  end
end
