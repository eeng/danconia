module Danconia
  describe Serializable do
    it 'money objects can be marshalled' do
      expect(Marshal.load(Marshal.dump(Money(5, 'USD')))).to eq Money(5, 'USD')
      expect(Marshal.load(Marshal.dump(Money(3.2, 'ARS')))).to eq Money(3.2, 'ARS')
    end
  end
end
