require 'delegate'
require 'bigdecimal'
require 'active_support'

module ActsAsMoney
  class Money < DelegateClass(BigDecimal)
    attr_reader :decimals
    alias :amount :__getobj__

    def initialize amount, decimals = 2
      @decimals = decimals
      super parse(amount).round(@decimals)
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
      ActiveSupport::NumberHelper.number_to_currency amount, precision: @decimals
    end

    def inspect
      "#<#{self.class.name} amount: #{amount} decimals: #{decimals}>"
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
