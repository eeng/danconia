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
      it 'addition' do
        expect(Money(3) + Money(2)).to eq Money(5)
        expect(Money(3.5) + 0.5).to eq Money(4)
        expect { Money(3.5) + 'a' }.to raise_error TypeError
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

      it 'should preserve the currency' do
        expect(Money(1, 'ARS') + 2).to eq Money(3, 'ARS')
        expect(Money(1, 'ARS') + Money(2, 'ARS')).to eq Money(3, 'ARS')
      end

      it 'should exchange the other currency if it is different' do
        expect(Money(1, 'ARS') + Money(1, 'USD', exchange: BasicExchange.new { 4 })).to eq Money(5, 'ARS')
      end

      it 'should return a new object with the same options' do
        m1 = Money(4, decimals: 3)
        m2 = m1 * 2
        expect(m2).to_not eql m1
        expect(m2.decimals).to eq 3
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

      it 'should exchange to the source currency if they differ' do
        with_config do |config|
          config.default_exchange = BasicExchange.new { 4 }

          expect(Money(3, 'ARS') < Money(1, 'USD')).to be true
          expect(Money(4, 'ARS') < Money(1, 'USD')).to be false
        end
      end

      it 'should work with uniq' do
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
        exchange = Object.new.tap do |o|
          def o.available_currencies
            [{code: 'EUR', symbol: '€'}, {code: 'JPY', symbol: '¥'}]
          end
        end
        with_config do |config|
          config.default_exchange = exchange

          expect(Money(1, 'EUR').to_s).to eq '€1.00'
          expect(Money(1, 'JPY').to_s).to eq '¥1.00'
          expect(Money(1, 'OTHER').to_s).to eq '$1.00'
        end
      end
    end

    context '.inspect' do
      it 'should display the object internals' do
        expect(Money(10.25, 'ARS', decimals: 3).inspect).to eq '#<Danconia::Money 10.25 ARS>'
      end
    end

    context 'exchange_to' do
      it 'should use the exchange passed to the instance to get the rate' do
        expect(Money(2, 'USD', exchange: BasicExchange.new { 3 }).exchange_to('ARS')).to eq Money(6, 'ARS')
      end

      it 'should use the default exchange if not set' do
        with_config do |config|
          config.default_exchange = BasicExchange.new do |src, dst|
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

      it 'exchange between the same currency is always 1' do
        expect(Money(5, 'EUR').exchange_to('EUR')).to eq Money(5, 'EUR')
      end

      it 'should return a new object with the same opts' do
        m1 = Money(1, 'USD', decimals: 0, exchange: BasicExchange.new { 3 })
        m2 = m1.exchange_to('ARS')
        expect(m2).to_not eql m1
        expect(m2.decimals).to eq 0
        expect(m1).to eq Money(1, 'USD')
      end
    end

    context 'delegation' do
      it 'should delegate missing methods to the amount' do
        expect(Money(10).positive?).to be true
        expect(Money(10).respond_to?(:positive?)).to be true
      end
    end
  end
end
