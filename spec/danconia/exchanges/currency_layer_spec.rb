require 'spec_helper'

module Danconia
  module Exchanges
    describe CurrencyLayer do
      subject { CurrencyLayer.new access_key: '[KEY]' }

      context 'fetch_rates' do
        it 'uses the API to retrive the rates' do
          stub_request(:get, 'http://www.apilayer.net/api/live?access_key=[KEY]').to_return body: <<~END
            {
                "success": true,
                "source": "USD",
                "quotes": {
                    "USDARS": 27.110001,
                    "USDAUD": 1.346196
                }
            }
          END
          expect(subject.fetch_rates).to eq 'USDARS' => 27.110001, 'USDAUD' => 1.346196
        end

        it 'when the API returns an error' do
          stub_request(:get, 'http://www.apilayer.net/api/live?access_key=[KEY]').to_return body: <<~END
            {
                "success": false,
                "error": {
                  "code": 104,
                  "info": "Your monthly usage limit has been reached. Please upgrade your subscription plan."
                }
            }
          END
          expect { subject.fetch_rates }.to raise_error Errors::APIError
        end
      end

      context 'update_rates!' do
        it 'fetches the rates and stores them' do
          expect(subject).to receive(:fetch_rates) { {'USDARS' => 3, 'USDAUD' => 4} }
          subject.update_rates!
          expect(subject.rates.size).to eq 2
          expect(subject.rate('USD', 'ARS')).to eq 3
          expect(subject.rate('USD', 'AUD')).to eq 4
        end

        it 'if a rate already exists should update it' do
          subject.store.save_rates 'USDARS' => 3
          expect(subject).to receive(:fetch_rates) { {'USDARS' => 3.1} }
          subject.update_rates!
          expect(subject.rate('USD', 'ARS')).to eq 3.1
        end
      end
    end
  end
end