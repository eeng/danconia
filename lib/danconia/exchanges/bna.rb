require 'danconia/errors/api_error'
require 'net/http'
require 'nokogiri'

module Danconia
  module Exchanges
    class BNA < Exchange
      def fetch_rates
        response = Net::HTTP.get URI 'https://www.bna.com.ar/Personas'
        doc = Nokogiri::XML(response).css('#billetes')

        if doc.css('thead th:last-child').text != 'Venta'
          raise Errors::APIError, 'Could not scrape BNA page. Maybe the format changed?'
        end

        doc.css('tbody tr').map do |row|
          pair = parse_pair(row.css('td:first-child').text)
          rate = parse_rate(row.css('td:last-child').text, pair)
          date = Date.parse(doc.css('.fechaCot').text)
          {pair: pair, rate: rate, date: date}
        end.presence or raise Errors::APIError, 'Could not scrape BNA page. Maybe the format changed?'
      end

      private

      def parse_pair cur_name
        case cur_name
        when /Dolar/ then 'USDARS'
        when /Euro/ then 'EURARS'
        when /Real/ then 'BRLARS'
        else raise Errors::APIError, "Currency '#{cur_name}' not recognized"
        end
      end

      def parse_rate str, pair
        val = Float(str.tr(',', '.'))
        pair == 'BRLARS' ? val / 100.0 : val
      end
    end
  end
end
