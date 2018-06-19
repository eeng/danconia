require 'test_helper'

module ActsAsMoney
  class Product < ActiveRecord::Base
    money :price, :tax, :discount
  end

  class MoneyAttributeAssignmentTest < Minitest::Test
    def test_rounding_new
      assert_equal 19.64, Product.new(price: (78.55 * 0.25).to_d).price
      assert_equal 0.67, Product.new(tax: 2.0/3.0).tax
    end

    def test_rounding_persisted
      assert_equal 0.67, Product.create(tax: 2.0/3.0).reload.tax
    end

    def test_nils
      assert_nil Product.new(price: nil).price
    end

    def test_other_types
      assert_equal 10, Product.new(price: 10).price
      assert_equal 10.24, Product.new(price: "10.235").price
    end

    def test_should_use_bigdecimal
      assert_equal BigDecimal, Product.new(price: 1).price.amount.class
      assert_equal Money, Product.new(price: 1).price.class
    end

    def test_should_use_scale_from_column_for_decimales_pieces
      assert_equal 3, Product.new(discount: 2).discount.decimals
      assert_equal 3, Product.create(discount: 2).reload.discount.decimals
    end
  end
end
