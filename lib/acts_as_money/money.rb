require 'delegate'
require 'bigdecimal'
require 'active_support'

module ActsAsMoney
  class Money < DelegateClass(BigDecimal)
    attr_reader :amount, :decimals

    def initialize amount, decimals = 2
      @decimals = decimals
      @amount = parse(amount).round(@decimals)
      super @amount
    end

    %w(+ - * /).each do |op|
      class_eval %Q{
        def #{op} other
          other = parse(other) if !other.is_a?(BigDecimal) && !other.is_a?(Money)
          Money.new super, decimals
        end
      }
    end

    def to_s
      ActiveSupport::NumberHelper.number_to_currency to_f, precision: @decimals
    end

    def inspect
      "#<#{self.class.name} amount: #{to_f} decimals: #{decimals}>"
    end

    def in_cents
      (self * 100).round
    end

    private

    def parse object
      BigDecimal(object.to_s) rescue BigDecimal('0')
    end
  end
end
