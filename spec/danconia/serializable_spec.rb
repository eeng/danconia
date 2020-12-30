module Danconia
  describe Serializable do
    context 'marshalling' do
      it 'money objects support dump and load' do
        expect(Marshal.load(Marshal.dump(Money(5, 'USD')))).to eq Money(5, 'USD')
        expect(Marshal.load(Marshal.dump(Money(3.2, 'ARS')))).to eq Money(3.2, 'ARS')
      end
    end

    context 'to_json' do
      it 'should delegate to the amount' do
        expect(Money(1).to_json).to eq %({"amount":"1.0","currency":"USD"})
      end
    end
  end
end
