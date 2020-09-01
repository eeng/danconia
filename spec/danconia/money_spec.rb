module Danconia
  describe Money do
    context 'instantiation' do
      it 'should accept integers and strings' do
        expect(Money(10).amount).to eq BigDecimal('10')
        expect(Money('10.235').amount).to eq BigDecimal('10.235')
      end

      it 'non numeric values are treated as zero' do
        expect(Money(nil)).to eq Money(0)
        expect(Money('a')).to eq Money(0)
      end

      it 'should use the default currency if not specified' do
        TestHelpers.with_config do |config|
          config.default_currency = 'ARS'
          expect(Money(0).currency.code).to eq 'ARS'

          config.default_currency = 'EUR'
          expect(Money(0).currency.code).to eq 'EUR'
        end
      end
    end

    context 'arithmetic' do
      it 'does the operation on the amount' do
        expect(Money(3) + Money(2)).to eq Money(5)
        expect(Money(3.5) + 0.5).to eq Money(4)
        expect(Money(78.55) * 0.25).to eq Money(19.6375)
        expect(Money(3) / 2).to eq Money(1.5)
        expect { Money(3.5) + 'a' }.to raise_error TypeError
      end

      it 'should preserve the currency' do
        expect(Money(1, 'ARS') + 2).to eq Money(3, 'ARS')
        expect(Money(1, 'ARS') + Money(2, 'ARS')).to eq Money(3, 'ARS')
      end

      it 'should exchange the other currency if it is different' do
        expect(Money(1, 'ARS', exchange: fake_exchange(rate: 4)) + Money(1, 'USD')).to eq Money(5, 'ARS')
      end

      it 'should return a new object with the same options' do
        e = fake_exchange
        m1 = Money(4, decimals: 3, exchange: e)
        m2 = m1 * 2
        expect(m2).to_not eql m1
        expect(m2.decimals).to eq 3
        expect(m2.exchange).to eq e
      end

      it 'round should return a money object with the same currency' do
        expect(Money(1.9, 'ARS').round).to eq Money(2, 'ARS')
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
        TestHelpers.with_rates 'USDARS' => 4 do |config|
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

    context 'format' do
      it 'allow to override the number of decimals' do
        expect(Money(3.561, decimals: 3).format(decimals: 1)).to eq '$3.6'
      end

      it 'pass the options to the activesupport helper' do
        expect(Money(2).format(format: '%n %u')).to eq '2.00 $'
      end
    end

    context 'to_s' do
      it 'should add the currency symbol' do
        expect(Money(3.25).to_s).to eq '$3.25'

        TestHelpers.with_config do |config|
          config.available_currencies = [{code: 'EUR', symbol: '€'}, {code: 'JPY', symbol: '¥'}]

          expect(Money(1, 'EUR').to_s).to eq '€1.00'
          expect(Money(1, 'JPY').to_s).to eq '¥1.00'
          expect(Money(1, 'OTHER').to_s).to eq '$1.00'
        end
      end

      it 'should round according to decimals' do
        expect(Money(3.256, decimals: 2).to_s).to eq '$3.26'
        expect(Money(3.2517, decimals: 3).to_s).to eq '$3.252'
      end
    end

    context '.inspect' do
      it 'should display the object internals' do
        expect(Money(10.25, 'ARS', decimals: 3).inspect).to eq '10.25 ARS'
      end
    end

    context 'exchange_to' do
      it 'should use a default exchange if not overriden' do
        TestHelpers.with_rates 'USDEUR' => 3, 'USDARS' => 4 do
          expect(Money(2, 'USD').exchange_to('EUR')).to eq Money(6, 'EUR')
          expect(Money(2, 'USD').exchange_to('ARS')).to eq Money(8, 'ARS')
        end
      end

      it 'should allow to pass the exchange to the instance' do
        expect(Money(2, 'USD', exchange: fake_exchange(rate: 3)).exchange_to('ARS')).to eq Money(6, 'ARS')
      end

      it 'should allow to pass the exchange when converting' do
        expect(Money(2, 'USD').exchange_to('ARS', exchange: fake_exchange(rate: 4))).to eq Money(8, 'ARS')
      end

      it 'when overriding the exchange, should preserve it in the new instances' do
        m1 = Money(1, 'USD').exchange_to('ARS', exchange: fake_exchange(rate: 2))
        m2 = m1 + Money(3, 'USD')
        m3 = m2 * Money(1, 'USD')
        expect(m2).to eq Money(8, 'ARS')
        expect(m3).to eq Money(16, 'ARS')
      end

      it 'if no rate if found should raise error' do
        expect { Money(2, 'USD').exchange_to('ARS') }.to raise_error Errors::ExchangeRateNotFound
      end

      it 'exchange between the same currency is always 1' do
        expect(Money(5, 'EUR').exchange_to('EUR')).to eq Money(5, 'EUR')
      end

      it 'should return a new object with the same opts' do
        m1 = Money(1, 'USD', decimals: 0, exchange: fake_exchange(rate: 3))
        m2 = m1.exchange_to('ARS')
        expect(m2).to_not eql m1
        expect(m2.decimals).to eq 0
        expect(m1).to eq Money(1, 'USD')
      end

      it 'if the destination currency is blank should not do the conversion' do
        expect(Money(1, 'USD').exchange_to('')).to eq Money(1, 'USD')
        expect(Money(1, 'ARS').exchange_to('')).to eq Money(1, 'ARS')
      end

      it 'allows to specify opts to pass to the exchange (filters for example)' do
        exchange = Class.new(Exchanges::Exchange) do
          def rates opts
            case opts[:type]
            when 'divisa' then {'USDARS' => 7}
            when 'billete' then {'USDARS' => 8}
            else {}
            end
          end
        end.new

        expect(Money(1, 'USD').exchange_to('ARS', type: 'divisa', exchange: exchange)).to eq Money(7, 'ARS')
        expect { Money(1, 'USD').exchange_to('ARS', exchange: exchange) }.to raise_error Errors::ExchangeRateNotFound
      end
    end

    context 'default_currency?' do
      it 'is true if the currency is the configured default' do
        TestHelpers.with_config do |config|
          config.default_currency = 'ARS'
          expect(Money(1, 'ARS')).to be_default_currency
          expect(Money(1, 'USD')).to_not be_default_currency
        end
      end
    end

    context 'delegation' do
      it 'should delegate missing methods to the amount' do
        expect(Money(10).positive?).to be true
        expect(Money(10).respond_to?(:positive?)).to be true
      end
    end

    context 'to_json' do
      it 'should delegate to the amount' do
        expect(Money(1).to_json).to eq '"1.0"'
      end
    end

    def fake_exchange args = {}
      double 'Danconia::Exchanges::Exchange', args.reverse_merge(rate: nil)
    end
  end
end
