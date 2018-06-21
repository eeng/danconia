require 'spec_helper'

module Danconia
  describe Money do
    context 'instantiation' do
      it 'should accept integers and strings' do
        expect(Money(10).amount).to eq BigDecimal('10')
        expect(Money('10.235').amount).to eq BigDecimal('10.24')
      end

      it 'non numeric values are treated as zero' do
        expect(Money('a')).to eq Money(0)
      end

      it 'should use the default currency if not specified' do
        with_config do |config|
          config.default_currency = 'ARS'
          expect(Money(0).currency.code).to eq 'ARS'

          config.default_currency = 'EUR'
          expect(Money(0).currency.code).to eq 'EUR'
        end
      end
    end

    context 'arithmetic' do
      it 'addition between Money instances' do
        res = Money(3, decimals: 4) + Money(2, decimals: 4)
        expect(res).to be_a Money
        expect(res.decimals).to eq 4
        expect(res.amount).to eq 5
      end

      it 'addition with other types' do
        expect(Money(3.5) + 0.5).to eq Money(4)
        expect(Money(3.5) + 'a').to eq Money(3.5)
      end

      it 'multiplication' do
        expect(Money(78.55) * 0.25).to eq Money(19.64)
        expect(Money(28.5) * 0.15).to eq Money(4.28)
        expect(Money(10.9906, decimals: 4) * 1.1).to eq Money(12.0897, decimals: 4)
        expect(Money(1) * 2).to be_a Money
      end

      it 'division' do
        expect(Money(2) / 3.0).to eq Money(0.67)
      end
    end

    context 'comparisson' do
      it 'two money objects are equal when the amount and currency are the same' do
        expect(Money(1.01)).to eq Money(1.01)
        expect(Money(1.01)).not_to eq Money(1.02)
        expect(Money(1, 'ARS')).to eq Money(1, 'ARS')
        expect(Money(1, 'USD')).not_to eq Money(1, 'ARS')
      end

      it 'allows to compare against numeric values when using the default currency' do
        expect(Money(1)).to eq 1
        expect(Money(1.35)).to eq 1.35
        expect(Money(1)).not_to eq 2
        expect(Money(1, 'ARS')).not_to eq 1
      end

      it 'when using uniq' do
        expect([Money(1), Money(1)].uniq.size).to eq 1
        expect([Money(1), Money(1.1)].uniq.size).to eq 2
        expect([Money(1, 'ARS'), Money(1, 'USD')].uniq.size).to eq 2
      end
    end

    context 'to_s' do
      it 'should round according to decimals' do
        expect(Money(3.25).to_s).to eq '$3.25'
        expect(Money(3.256, decimals: 3).to_s).to eq '$3.256'
      end

      it 'nil should be like zero' do
        expect(Money(nil).to_s).to eq '$0.00'
      end

      it 'with other currencies' do
        with_config do |config|
          config.available_currencies = [{code: 'EUR', symbol: '€'}, {code: 'JPY', symbol: '¥'}]

          expect(Money(1, 'EUR').to_s).to eq '€1.00'
          expect(Money(1, 'JPY').to_s).to eq '¥1.00'
          expect(Money(1, 'OTHER').to_s).to eq '$1.00'
        end
      end
    end

    context '.inspect' do
      it 'should display the object internals' do
        expect(Money(10.25).inspect).to eq '#<Danconia::Money amount: 10.25, currency: USD, decimals: 2>'
        expect(Money(10.25, 'ARS', decimals: 3).inspect).to eq '#<Danconia::Money amount: 10.25, currency: ARS, decimals: 3>'
      end
    end

    context 'exchange_to' do
      it 'should use the configured function to get the exchange rate' do
        with_config do |config|
          config.get_exchange_rate = -> src, dst do
            {
              'USD->EUR' => 3,
              'USD->ARS' => 4,
            }["#{src}->#{dst}"]
          end

          expect(Money(2, 'USD').exchange_to('EUR')).to eq Money(6, 'EUR')
          expect(Money(2, 'USD').exchange_to('ARS')).to eq Money(8, 'ARS')
        end
      end

      it 'if no rate if found should raise error' do
        expect { Money(2, 'USD').exchange_to('ARS') }.to raise_error Errors::ExchangeRateNotFound
      end
    end
  end
end
