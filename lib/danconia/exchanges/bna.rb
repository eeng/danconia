require 'danconia/errors/api_error'
require 'net/http'
require 'nokogiri'
require 'date'

module Danconia
  module Exchanges
    # The BNA does not provide an API to pull the rates, so this implementation scrapes the home HTML directly.
    # Returns rates of both types, "Billetes" and "Divisas", and only the "tipo de cambio vendedor" ones.
    # See `examples/bna.rb` for a complete usage example.
    class BNA < Exchange
      attr_reader :store

      def initialize store: Stores::InMemory.new
        @store = store
      end

      def fetch_rates
        response = Net::HTTP.get URI 'https://www.bna.com.ar/Personas'
        scrape_rates(response, 'billetes') + scrape_rates(response, 'divisas')
      end

      def update_rates!
        @store.save_rates fetch_rates
      end

      def rates rate_type:, **opts
        rs = @store.rates(opts).select { |er| er[:rate_type] == rate_type }
        Hash[rs.map { |er| er.values_at(:pair, :rate) }]
      end

      private

      def scrape_rates response, type
        doc = Nokogiri::XML(response).css("##{type}")

        if doc.css('thead th:last-child').text != 'Venta'
          raise Errors::APIError, "Could not scrape '#{type}' rates. Maybe the format changed?"
        end

        doc.css('tbody tr').map do |row|
          pair = parse_pair(row.css('td:first-child').text) or next
          rate = parse_rate(row.css('td:last-child').text, pair)
          date = Date.parse(doc.css('.fechaCot').text)
          {pair: pair, rate: rate, date: date, rate_type: type}
        end.compact.presence or raise Errors::APIError, "Could not scrape '#{type}' rates. Maybe the format changed?"
      end

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
