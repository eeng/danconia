require 'danconia/exchanges/currency_layer'

module Danconia
  module Exchanges
    describe CurrencyLayer do
      subject { CurrencyLayer.new access_key: '[KEY]' }

      context 'fetch_rates' do
        it 'uses the API to retrive the rates' do
          stub_request(:get, 'http://www.apilayer.net/api/live?access_key=[KEY]').to_return body: fixture('success.json')
          expect(subject.fetch_rates).to eq 'USDARS' => 27.110001, 'USDAUD' => 1.346196
        end

        it 'when the API returns an error' do
          stub_request(:get, 'http://www.apilayer.net/api/live?access_key=[KEY]').to_return body: fixture('failure.json')
          expect { subject.fetch_rates }.to raise_error Errors::APIError
        end

        def fixture file
          File.read("#{__dir__}/fixtures/currency_layer/#{file}")
        end
      end

      context 'update_rates!' do
        it 'fetches the rates and stores them' do
          store = instance_double('store')
          rates = {'USDARS' => 3, 'USDAUD' => 4}

          exchange = CurrencyLayer.new(access_key: '...', store: store)

          expect(exchange).to receive(:fetch_rates).and_return(rates)
          expect(store).to receive(:save_rates).with(rates)

          exchange.update_rates!
        end
      end
    end
  end
end
