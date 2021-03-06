module Danconia
  module Exchanges
    describe Exchange do
      context 'rate' do
        it 'returns the exchange rate value for the supplied currencies' do
          exchange = fake_exchange('USDEUR' => 3, 'USDARS' => 4)
          expect(exchange.rate('USD', 'EUR')).to eq 3
          expect(exchange.rate('USD', 'ARS')).to eq 4
        end

        it 'if the direct conversion is not found, tries to find the inverse' do
          exchange = fake_exchange('USDEUR' => 3)
          expect(exchange.rate('EUR', 'USD')).to be_within(0.00001).of(1.0 / 3)
        end

        it 'if not direct nor inverse conversion is found, tries to convert through USD' do
          exchange = fake_exchange('USDEUR' => 3, 'USDARS' => 6)
          expect(exchange.rate('EUR', 'ARS')).to be_within(0.00001).of 2
          expect(exchange.rate('ARS', 'EUR')).to be_within(0.00001).of 0.5
        end

        it 'pairs can have a different common currency' do
          exchange = fake_exchange('EURARS' => 3, 'BRLARS' => 1.5)
          expect(exchange.rate('EUR', 'ARS')).to eq 3
          expect(exchange.rate('ARS', 'EUR')).to be_within(0.00001).of(1.0 / 3)
          expect(exchange.rate('BRL', 'ARS')).to eq 1.5
          expect(exchange.rate('EUR', 'BRL')).to eq 3 / 1.5
        end

        it 'raises an error if the conversion cannot be made' do
          expect { fake_exchange({}).rate('USD', 'EUR') }.to raise_error Errors::ExchangeRateNotFound
        end

        it 'should allow to pass options to filter the rates' do
          exchange = Class.new(Exchange) do
            def rates type:
              case type
              when 'divisa' then {'USDARS' => 7}
              when 'billete' then {'USDARS' => 8}
              end
            end
          end.new

          expect(exchange.rate('USD', 'ARS', type: 'divisa')).to eq 7
          expect(exchange.rate('USD', 'ARS', type: 'billete')).to eq 8
        end

        def fake_exchange(rates)
          FixedRates.new(rates: rates)
        end
      end
    end
  end
end
