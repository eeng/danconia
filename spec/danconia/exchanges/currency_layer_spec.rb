require 'danconia/exchanges/currency_layer'

module Danconia
  module Exchanges
    describe CurrencyLayer do
      context 'fetch_rates' do
        subject { CurrencyLayer.new access_key: '[KEY]' }

        it 'uses the API to retrive the rates' do
          stub_request(:get, 'http://www.apilayer.net/api/live?access_key=[KEY]')
            .to_return(body: fixture('success.json'))

          expect(subject.fetch_rates).to eq 'USDARS' => 27.110001, 'USDAUD' => 1.346196
        end

        it 'when the API returns an error' do
          stub_request(:get, 'http://www.apilayer.net/api/live?access_key=[KEY]')
            .to_return(body: fixture('failure.json'))

          expect { subject.fetch_rates }.to raise_error Errors::APIError
        end

        def fixture file
          File.read("#{__dir__}/fixtures/currency_layer/#{file}")
        end
      end

      context 'update_rates!' do
        it 'fetches the rates and stores them' do
          store = double('store')
          expect(store).to receive(:save_rates).with([{pair: 'USDARS', rate: 3}, {pair: 'USDAUD', rate: 4}])

          exchange = CurrencyLayer.new(access_key: '...', store: store)
          allow(exchange).to receive(:fetch_rates).and_return('USDARS' => 3, 'USDAUD' => 4)
          exchange.update_rates!
        end
      end

      context 'rates' do
        it 'converts the array from the store back to a map of pair to rates' do
          store = double('store')
          expect(store).to receive(:rates).and_return([{pair: 'USDARS', rate: 3}, {pair: 'USDAUD', rate: 4}])

          exchange = CurrencyLayer.new(access_key: '...', store: store)
          expect(exchange.rates).to eq 'USDARS' => 3, 'USDAUD' => 4
        end
      end
    end
  end
end
