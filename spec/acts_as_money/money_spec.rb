require 'spec_helper'

module ActsAsMoney
  describe Money do
    context 'instantiation' do
      it 'should accept integers and strings' do
        expect(Money.new(10).amount).to eq BigDecimal('10')
        expect(Money.new('10.235').amount).to eq BigDecimal('10.24')
      end

      it 'non numeric values are treated as zero' do
        expect(Money.new('a')).to eq 0
      end
    end

    context 'arithmetic' do
      it 'addition between Money instances' do
        res = Money.new(3, decimals: 4) + Money.new(2, decimals: 4)
        expect(res).to be_a Money
        expect(res.decimals).to eq 4
        expect(res.amount).to eq 5
      end

      it 'addition with other types' do
        expect(Money.new(3.5) + 0.5).to eq 4
        expect(Money.new(3.5) + 'a').to eq 3.5
      end

      it 'multiplication' do
        expect(Money.new(78.55) * 0.25).to eq 19.64
        expect(Money.new(28.5) * 0.15).to eq 4.28
        expect(Money.new(10.9906, decimals: 4) * 1.1).to eq 12.0897
        expect(Money.new(1) * 2).to be_a Money
      end

      it 'division' do
        expect(Money.new(2) / 3.0).to eq 0.67
      end
    end

    context 'comparisson' do
      it 'should be ==' do
        expect(Money.new(1) == Money.new(1)).to be true
      end

      it 'when using uniq' do
        expect([Money.new(1), Money.new(1)].uniq.size).to eq 1
        expect([Money.new(1), Money.new(1.1)].uniq.size).to eq 2
      end
    end

    context 'to_s' do
      it 'should round according to decimals' do
        expect(Money.new(3.25).to_s).to eq '$3.25'
        expect(Money.new(3.256, decimals: 3).to_s).to eq '$3.256'
      end

      it 'nil should be like zero' do
        expect(Money.new(nil).to_s).to eq '$0.00'
      end

      it 'with other currencies' do
        with_config do |config|
          config.available_currencies = [{code: 'EUR', symbol: '€'}, {code: 'JPY', symbol: '¥'}]

          expect(Money.new(1, 'EUR').to_s).to eq '€1.00'
          expect(Money.new(1, 'JPY').to_s).to eq '¥1.00'
          expect(Money.new(1, 'OTHER').to_s).to eq '$1.00'
        end
      end
    end

    context '.inspect' do
      it 'should display the object internals' do
        expect(Money.new(10.25).inspect).to eq '#<ActsAsMoney::Money amount: 10.25 currency: USD decimals: 2>'
        expect(Money.new(10.25, 'ARS', decimals: 3).inspect).to eq '#<ActsAsMoney::Money amount: 10.25 currency: ARS decimals: 3>'
      end
    end
  end
end
