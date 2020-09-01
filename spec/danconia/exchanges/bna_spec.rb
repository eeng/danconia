require 'spec_helper'
require 'danconia/exchanges/bna'

module Danconia
  module Exchanges
    describe BNA do
      subject { BNA.new }

      context 'fetch_rates' do
        it 'scrapes the html and returns current rates' do
          stub_request(:get, 'https://www.bna.com.ar/Personas').to_return body: fixture('home.html')

          expect(subject.fetch_rates).to eq [
            {pair: 'USDARS', rate: 78.25, date: Date.new(2020, 9, 1)},
            {pair: 'EURARS', rate: 89, date: Date.new(2020, 9, 1)},
            {pair: 'BRLARS', rate: 14.5, date: Date.new(2020, 9, 1)}
          ]
        end

        it 'raise error if cannot parse the document' do
          stub_request(:get, 'https://www.bna.com.ar/Personas').to_return body: 'some invalid html'

          expect { subject.fetch_rates }.to raise_error Errors::APIError
        end
      end

      def fixture file
        File.read("#{__dir__}/fixtures/bna/#{file}")
      end
    end
  end
end
