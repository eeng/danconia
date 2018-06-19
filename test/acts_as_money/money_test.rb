require 'test_helper'

module ActsAsMoney
  class OperationsTest < Minitest::Test
    def test_rounding_multiplication
      assert_equal 19.64, Money.new(78.55) * 0.25
      assert_equal 4.28, Money.new(28.5) * 0.15
      assert_equal 12.0897, Money.new(10.9906, 4) * 1.1
    end

    def test_rounding_division
      assert_equal 0.67, Money.new(2) / 3.0
    end

    def test_should_return_money
      assert_equal Money, (Money.new(1) * 2).class
    end

    def test_sum_should_return_money
      res = Money.new(3, 4) + Money.new(2, 4)
      assert_equal Money, res.class
      assert_equal 4, res.decimals
      assert_equal 5, res
    end
  end

  class ComparissonTest < Minitest::Test
    def test_should_be_equal
      assert Money.new(1) == Money.new(1)
    end

    def test_should_be_uniq
      assert_equal 1, [Money.new(1), Money.new(1)].uniq.size
      assert_equal 2, [Money.new(1), Money.new(1.1)].uniq.size
    end
  end

  class ToStringTest < Minitest::Test
    def test_when_nil
      assert_equal "$0.00", Money.new(nil).to_s
    end

    def test_when_not_null
      assert_equal "$3.25", Money.new(3.25).to_s
      assert_equal "$3.256", Money.new(3.256, 3).to_s
    end
  end

  class InCentsTest < Minitest::Test
    def test_should_multiply_by_100_and_round
      assert_equal 326, Money.new(3.256).in_cents
    end
  end

  class InspectTest < Minitest::Test
    def test_should_contain_class_and_attributes
      assert_equal '#<ActsAsMoney::Money amount: 10.0 decimals: 3>', Money.new(10, 3).inspect
    end
  end
end