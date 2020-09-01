require 'spec_helper'
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
      end

      def fixture file
        File.read("#{__dir__}/fixtures/currency_layer/#{file}")
      end
    end
  end
end
