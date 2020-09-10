require 'danconia/exchanges/bna'

module Danconia
  module Exchanges
    describe BNA do
      subject { BNA.new }

      context 'fetch_rates' do
        it 'extracts the rates from the html' do
          stub_request(:get, 'https://www.bna.com.ar/Personas').to_return body: fixture('home.html')
          rates = subject.fetch_rates

          expect(rates.select { |r| r[:rate_type] == 'billetes' }).to eq [
            {pair: 'USDARS', rate: 78.25, date: Date.new(2020, 9, 1), rate_type: 'billetes'},
            {pair: 'EURARS', rate: 89, date: Date.new(2020, 9, 1), rate_type: 'billetes'},
            {pair: 'BRLARS', rate: 14.5, date: Date.new(2020, 9, 1), rate_type: 'billetes'}
          ]

          expect(rates.select { |r| r[:rate_type] == 'divisas' }).to eq [
            {pair: 'USDARS', rate: 74.18, date: Date.new(2020, 8, 31), rate_type: 'divisas'},
            {pair: 'EURARS', rate: 88.6822, date: Date.new(2020, 8, 31), rate_type: 'divisas'}
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

      context 'rates' do
        it 'pass the params to the store and converts the array of rates back to hash' do
          store = double('store')
          expect(store).to receive(:rates)
            .with(rate_type: 'billetes', date: nil)
            .and_return([{pair: 'USDARS', rate: 3}])

          exchange = BNA.new(store: store)
          expect(exchange.rates(rate_type: 'billetes')).to eq 'USDARS' => 3
        end

        it 'rate_type is required' do
          expect { BNA.new.rates }.to raise_error ArgumentError
        end
      end
    end
  end
end
