module Danconia
  module Stores
    describe ActiveRecord, active_record: true do
      before do
        ::ActiveRecord::Schema.define do
          create_table :exchange_rates do |t|
            t.string :pair, limit: 6
            t.decimal :rate, precision: 12, scale: 6
            t.string :rate_type
          end
        end
      end

      context 'save_rates' do
        it 'should create or update the rates' do
          ExchangeRate.create! pair: 'USDEUR', rate: 2

          expect do
            subject.save_rates [{pair: 'USDEUR', rate: 3}, {pair: 'USDARS', rate: 4}]
          end.to change { ExchangeRate.count }.by 1

          expect(subject.rates).to match [
            include(pair: 'USDEUR', rate: 3),
            include(pair: 'USDARS', rate: 4)
          ]
        end

        it 'allows to specify other keys to use as unique' do
          store = ActiveRecord.new(unique_keys: %i[pair rate_type])
          store.save_rates [
            {pair: 'USDARS', rate: 3, rate_type: 'billetes'},
            {pair: 'USDARS', rate: 4, rate_type: 'divisas'}
          ]
          store.save_rates [
            {pair: 'USDARS', rate: 33, rate_type: 'billetes'}
          ]
          expect(subject.rates).to match [
            include(pair: 'USDARS', rate: 33, rate_type: 'billetes'),
            include(pair: 'USDARS', rate: 4, rate_type: 'divisas')
          ]
        end
      end

      context 'rates' do
        it 'returns an array like the one it received' do
          ExchangeRate.create! pair: 'USDEUR', rate: 2
          ExchangeRate.create! pair: 'USDARS', rate: 40

          expect(subject.rates).to match [
            include(pair: 'USDEUR', rate: 2),
            include(pair: 'USDARS', rate: 40)
          ]
        end
      end
    end
  end
end
