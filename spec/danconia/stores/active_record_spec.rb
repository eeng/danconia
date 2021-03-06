module Danconia
  module Stores
    describe ActiveRecord, active_record: true do
      before do
        ::ActiveRecord::Schema.define do
          create_table :exchange_rates do |t|
            t.string :pair, limit: 6
            t.decimal :rate, precision: 12, scale: 6
            t.string :rate_type
            t.date :date
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

        it 'ignores fields not present in the database table' do
          subject.save_rates [{pair: 'USDEUR', rate: 3, non_existant: 'ignoreme'}]
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

        it 'allows to pass filters' do
          store = ActiveRecord.new(unique_keys: %i[pair date])
          store.save_rates [
            {pair: 'USDEUR', rate: 10, date: Date.new(2020, 1, 1)},
            {pair: 'USDEUR', rate: 20, date: Date.new(2020, 1, 2)},
            {pair: 'USDEUR', rate: 30, date: Date.new(2020, 1, 3)}
          ]

          expect(store.rates.size).to eq 3
          expect(store.rates(date: Date.new(2020, 1, 2))).to match [include(rate: 20)]
        end
      end

      context 'special date field' do
        let(:store) do
          store = ActiveRecord.new(unique_keys: %i[pair date], date_field: :date)
          store.save_rates [
            {pair: 'USDEUR', rate: 10, date: Date.new(2000, 1, 1)},
            {pair: 'USDEUR', rate: 20, date: Date.new(2000, 1, 2)},
            {pair: 'USDEUR', rate: 30, date: Date.new(2000, 1, 4)}
          ]
          store
        end

        it 'calling #rates with a particular date when there are rates for that date' do
          expect(store.rates(date: Date.new(2000, 1, 2))).to match [include(rate: 20)]
        end

        it 'calling #rates with a particular date when there are not rates for that date should return the previous' do
          expect(store.rates(date: Date.new(2000, 1, 3))).to match [include(rate: 20)]
          expect(store.rates(date: Date.new(1999, 12, 31))).to eq []
        end

        it 'calling #rates without a particular date, uses today' do
          expect(store.rates).to match [include(rate: 30)]
        end
      end
    end
  end
end
