require 'spec_helper'
require 'danconia/exchanges/currency_layer'

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
          expect(subject.fetch_rates).to eq [
            {from: 'USD', to: 'ARS', rate: 27.110001},
            {from: 'USD', to: 'AUD', rate: 1.346196},
          ]
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

      context 'store_rates', active_record: true do
        it 'creates the rates if they dont already exists' do
          expect {
            subject.store_rates [
              {from: 'USD', to: 'ARS', rate: 27.110001},
              {from: 'USD', to: 'AUD', rate: 1.346196}
            ]
          }.to change { ExchangeRate.count }.by 2
          expect(ExchangeRate.first).to have_attributes from: 'USD', to: 'ARS', rate: 27.110001
        end

        it 'otherwise update the rate' do
          er = ExchangeRate.create! from: 'USD', to: 'ARS', rate: 25
          expect {
            subject.store_rates [{from: 'USD', to: 'ARS', rate: 27}]
          }.to_not change { ExchangeRate.count }
          expect(er.reload.rate).to eq 27
        end
      end

      context 'update_rates!', active_record: true do
        it 'fetches the rates and stores them' do
          expect(subject).to receive(:fetch_rates) { [{from: 'USD', to: 'ARS', rate: 3}] }
          expect { subject.update_rates! }.to change { ExchangeRate.count }
        end
      end

      context 'rate', active_record: true do
        it 'returns the exchange rate value for the supplied currencies' do
          ExchangeRate.create! from: 'USD', to: 'EUR', rate: 3
          ExchangeRate.create! from: 'USD', to: 'ARS', rate: 4
          expect(subject.rate 'USD', 'EUR').to eq 3
          expect(subject.rate 'USD', 'ARS').to eq 4
        end

        it 'returns nil if not found' do
          expect(subject.rate 'USD', 'EUR').to eq nil
        end

        it 'if the direct conversion is not found, tries to find the inverse' do
          ExchangeRate.create! from: 'USD', to: 'EUR', rate: 3
          expect(subject.rate 'EUR', 'USD').to eq BigDecimal(1) / 3
        end

        it 'if not direct nor inverse conversion is found and both are different than USD, tries to convert through USD' do
          ExchangeRate.create! from: 'USD', to: 'EUR', rate: 3
          ExchangeRate.create! from: 'USD', to: 'ARS', rate: 6
          expect(subject.rate 'EUR', 'ARS').to be_within(0.000001).of 2
          expect(subject.rate 'ARS', 'EUR').to be_within(0.000001).of 0.5
        end
      end

      before :each, :active_record do
        ActiveRecord::Schema.define do
          create_table :exchange_rates do |t|
            t.string :from, :to, limit: 3
            t.decimal :rate, precision: 12, scale: 6
          end
        end
      end
    end
  end
end