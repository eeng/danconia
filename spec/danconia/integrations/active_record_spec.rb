require 'spec_helper'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

class Product < ActiveRecord::Base
  money :price, :tax, :discount, :cost
end

module Danconia
  describe Integrations::ActiveRecord do
    context 'single currency' do
      it 'setter' do
        expect(Product.new(price: 1.536).read_attribute :price).to eq 1.54
        expect(Product.new(price: nil).read_attribute :price).to eq nil
        expect(Product.new(price: Money(3)).read_attribute :price).to eq 3
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
        expect(Product.new(cost: Money(1, 'ARS'))).to have_attributes cost_amount: 1, cost_currency: 'ARS'
        expect(Product.new(cost: 2)).to have_attributes cost_amount: 2, cost_currency: nil
        expect(Product.new(cost: nil)).to have_attributes cost_amount: nil, cost_currency: nil
      end

      it 'getter' do
        expect(Product.new(cost_amount: 1, cost_currency: 'ARS').cost).to eq Money(1, 'ARS')
        expect(Product.new(cost_amount: 1, cost_currency: nil).cost).to eq Money(1, 'USD')
      end
    end

    before do
      ActiveRecord::Schema.define version: 1 do
        create_table :products do |t|
          t.column :price, :decimal, precision: 12, scale: 2
          t.column :tax, :decimal, precision: 12, scale: 2
          t.column :discount, :decimal, precision: 12, scale: 3
          t.column :cost_amount, :decimal, precision: 6, scale: 2
          t.column :cost_currency, :string, limit: 3
        end
      end
    end

    after do
      ActiveRecord::Base.connection.tables.each do |table|
        ActiveRecord::Base.connection.drop_table(table)
      end
    end
  end
end
