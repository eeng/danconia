module Danconia
  module Stores
    describe InMemory do
      context 'rates' do
        it 'filters rates by type' do
          subject.save_rates [
            {pair: 'USDARS', rate: 3, rate_type: 'divisas'},
            {pair: 'USDARS', rate: 4, rate_type: 'billetes'}
          ]

          expect(subject.rates(rate_type: 'divisas')).to match [include(rate: 3)]
          expect(subject.rates(rate_type: 'billetes')).to match [include(rate: 4)]
          expect(subject.rates).to match [include(rate: 3), include(rate: 4)]
        end
      end
    end
  end
end
