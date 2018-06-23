require 'spec_helper'

module Danconia
  module Stores
    describe ActiveRecord, active_record: true do
      context 'save_rates' do
        it 'should create or update the rates' do
          ExchangeRate.create! pair: 'USDEUR', rate: 2
          expect { subject.save_rates 'USDEUR' => 3, 'USDARS' => 4 }.to change { ExchangeRate.count }.by 1
          expect(subject.rates.map { |e| [e.pair, e.rate] }).to eq({'USDEUR' => 3, 'USDARS' => 4}.to_a)
        end
      end

      context '#direct_rate' do
        it 'should find the rate for the pair' do
          ExchangeRate.create! pair: 'USDEUR', rate: 2
          expect(subject.direct_rate('USD', 'EUR')).to eq 2
          expect(subject.direct_rate('USD', 'ARS')).to eq nil
        end
      end

      before do
        ::ActiveRecord::Schema.define do
          create_table :exchange_rates do |t|
            t.string :pair, limit: 6
            t.decimal :rate, precision: 12, scale: 6
            t.index :pair, unique: true
          end
        end
      end
    end
  end
end
