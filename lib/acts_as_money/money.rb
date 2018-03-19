require 'delegate'

module ActsAsMoney
  class Money < DelegateClass(BigDecimal)
    attr_reader :amount, :decimals

    def initialize amount, decimals = 2
      @decimals = decimals
      amount = 0 unless amount
      @amount = amount.to_s.to_d.round(@decimals)
      super @amount
    end

    %w(+ - * /).each do |op|
      class_eval %Q{
        def #{op} other
          other = other.to_s.to_d if !other.is_a?(BigDecimal) && !other.is_a?(Money)
          Money.new super, decimals
        end
      }
    end

    def hash
      @amount.hash
    end

    def eql? other
      @amount == other.amount
    end

    def to_s
      ActiveSupport::NumberHelper.number_to_currency to_d
    end

    def inspect
      to_s
    end

    def in_cents
      (self * 100).round
    end
  end
end