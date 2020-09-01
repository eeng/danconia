require 'danconia/errors/api_error'
require 'net/http'
require 'nokogiri'
require 'date'

module Danconia
  module Exchanges
    class BNA < Exchange
      def fetch_rates
        response = Net::HTTP.get URI 'https://www.bna.com.ar/Personas'
        scrape_rates(response, 'billetes') + scrape_rates(response, 'divisas')
      end

      def scrape_rates response, type
        doc = Nokogiri::XML(response).css("##{type}")

        if doc.css('thead th:last-child').text != 'Venta'
          raise Errors::APIError, "Could not scrape '#{type}' rates. Maybe the format changed?"
        end

        doc.css('tbody tr').map do |row|
          pair = parse_pair(row.css('td:first-child').text) or next
          rate = parse_rate(row.css('td:last-child').text, pair)
          date = Date.parse(doc.css('.fechaCot').text)
          {pair: pair, rate: rate, date: date, type: type}
        end.compact.presence or raise Errors::APIError, "Could not scrape '#{type}' rates. Maybe the format changed?"
      end

      private

      def parse_pair cur_name
        case cur_name
        when 'Dolar U.S.A' then 'USDARS'
        when 'Euro' then 'EURARS'
        when 'Real *' then 'BRLARS'
        end
      end

      def parse_rate str, pair
        val = Float(str.tr(',', '.'))
        pair == 'BRLARS' ? val / 100.0 : val
      end
    end
  end
end
