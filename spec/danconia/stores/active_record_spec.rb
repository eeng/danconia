module Danconia
  module Stores
    describe ActiveRecord, active_record: true do
      before do
        ::ActiveRecord::Schema.define do
          create_table :exchange_rates do |t|
            t.string :pair, limit: 6
            t.decimal :rate, precision: 12, scale: 6
            t.index :pair, unique: true
          end
        end
      end

      context 'save_rates' do
        it 'should create or update the rates' do
          ExchangeRate.create! pair: 'USDEUR', rate: 2
          expect { subject.save_rates 'USDEUR' => 3, 'USDARS' => 4 }.to change { ExchangeRate.count }.by 1
          expect(subject.rates).to eq('USDEUR' => 3, 'USDARS' => 4)
        end
      end

      context 'rates' do
        it 'returns a hash with rate by pair' do
          ExchangeRate.create! pair: 'USDEUR', rate: 2
          ExchangeRate.create! pair: 'USDARS', rate: 40
          expect(subject.rates).to eq('USDEUR' => 2, 'USDARS' => 40)
        end
      end
    end
  end
end
