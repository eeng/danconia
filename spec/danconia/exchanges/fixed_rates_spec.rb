require 'spec_helper'

module Danconia
  module Exchanges
    describe FixedRates do
      context 'rate' do
        it 'returns the exchange rate value for the supplied currencies' do
          exchange = FixedRates.new rates: {'USDEUR' => 3, 'USDARS' => 4}
          expect(exchange.rate 'USD', 'EUR').to eq 3
          expect(exchange.rate 'USD', 'ARS').to eq 4
        end

        it 'returns nil if not found' do
          expect { subject.rate 'USD', 'EUR' }.to raise_error Errors::ExchangeRateNotFound
        end

        it 'if the direct conversion is not found, tries to find the inverse' do
          exchange = FixedRates.new rates: {'USDEUR' => 3}
          expect(exchange.rate 'EUR', 'USD').to eq (1.0 / 3).round 6
        end

        it 'if not direct nor inverse conversion is found and both are different than USD, tries to convert through USD' do
          exchange = FixedRates.new rates: {'USDEUR' => 3, 'USDARS' => 6}
          expect(exchange.rate 'EUR', 'ARS').to be_within(0.00001).of 2
          expect(exchange.rate 'ARS', 'EUR').to be_within(0.00001).of 0.5
        end
      end
    end
  end
end
