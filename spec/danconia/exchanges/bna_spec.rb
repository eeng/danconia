require 'danconia/exchanges/bna'

module Danconia
  module Exchanges
    describe BNA do
      subject { BNA.new }

      context 'fetch_rates' do
        it 'extracts the rates from the html' do
          stub_request(:get, 'https://www.bna.com.ar/Personas').to_return body: fixture('home.html')
          rates = subject.fetch_rates

          expect(rates.select { |r| r[:type] == 'billetes' }).to eq [
            {pair: 'USDARS', rate: 78.25, date: Date.new(2020, 9, 1), type: 'billetes'},
            {pair: 'EURARS', rate: 89, date: Date.new(2020, 9, 1), type: 'billetes'},
            {pair: 'BRLARS', rate: 14.5, date: Date.new(2020, 9, 1), type: 'billetes'}
          ]

          expect(rates.select { |r| r[:type] == 'divisas' }).to eq [
            {pair: 'USDARS', rate: 74.18, date: Date.new(2020, 8, 31), type: 'divisas'},
            {pair: 'EURARS', rate: 88.6822, date: Date.new(2020, 8, 31), type: 'divisas'}
          ]
        end

        it 'raise error if cannot parse the document' do
          stub_request(:get, 'https://www.bna.com.ar/Personas').to_return body: 'some invalid html'
          expect { subject.fetch_rates }.to raise_error Errors::APIError
        end

        def fixture file
          File.read("#{__dir__}/fixtures/bna/#{file}")
        end
      end
    end
  end
end
