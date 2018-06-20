require 'spec_helper'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

class Product < ActiveRecord::Base
  money :price, :tax, :discount
end

module Danconia
  describe Integrations::ActiveRecord do
    it 'should convert attributes on instantiation' do
      expect(Product.new(price: 78.55 * 0.25).price).to eq Money.new(19.64)
    end

    it 'should convert back after loading' do
      expect(Product.create(tax: 2.0/3.0).reload.tax).to eq Money.new(0.67)
    end

    it 'should allow nil values' do
      expect(Product.new(price: nil).price).to be nil
    end

    it 'should use the scale from the columns as decimals' do
      expect(Product.new(discount: 2).discount.decimals).to eq 3
      expect(Product.create(discount: 2).reload.discount.decimals).to eq 3
    end

    before do
      ActiveRecord::Schema.define version: 1 do
        create_table :products do |t|
          t.column :price, :decimal, precision: 12, scale: 2
          t.column :tax, :decimal, precision: 12, scale: 2
          t.column :discount, :decimal, precision: 12, scale: 3
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
