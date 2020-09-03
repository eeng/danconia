module Danconia
  describe Integrations::ActiveRecord, active_record: true do
    context 'single currency' do
      it 'setter' do
        expect(Product.new(price: 1.536).read_attribute(:price)).to eq 1.54
        expect(Product.new(price: nil).read_attribute(:price)).to eq nil
        expect(Product.new(price: Money(3)).read_attribute(:price)).to eq 3
      end

      it 'getter' do
        expect(Product.new(price: 1).price).to eq Money(1)
        expect(Product.new(price: nil).price).to eq nil
      end

      it 'should use the scale from the columns as decimals' do
        expect(Product.new(discount: 2).discount.decimals).to eq 3
      end
    end

    context 'multicurrency support' do
      it 'setter' do
        expect(Product.new(cost: Money(1, 'ARS')).attributes.values_at('cost', 'cost_currency')).to eq [1, 'ARS']
        expect(Product.new(cost: 2).attributes.values_at('cost', 'cost_currency')).to eq [2, nil]
        expect(Product.new(cost: nil).attributes.values_at('cost', 'cost_currency')).to eq [nil, nil]
      end

      it 'getter' do
        expect(Product.new(cost: 1, cost_currency: 'ARS').cost).to eq Money(1, 'ARS')
        expect(Product.new(cost_currency: 'ARS', cost: 1).cost).to eq Money(1, 'ARS')
        expect(Product.new(cost: 1, cost_currency: nil).cost).to eq Money(1, 'USD')
        expect(Product.new(cost: nil, cost_currency: nil).cost).to eq nil
      end
    end

    class Product < ActiveRecord::Base
      money :price, :tax, :discount, :cost
    end

    before do
      ActiveRecord::Schema.define version: 1 do
        create_table :products do |t|
          t.column :price, :decimal, precision: 12, scale: 2
          t.column :tax, :decimal, precision: 12, scale: 2
          t.column :discount, :decimal, precision: 12, scale: 3
          t.column :cost, :decimal, precision: 6, scale: 2
          t.column :cost_currency, :string, limit: 3
        end
      end
    end
  end
end
