require "acts_as_money/version"
require "acts_as_money/money"

module ActsAsMoney
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def money(*attr_names)
      attr_names.each do |attr_name|
        generator = lambda { |x|
          decimals = columns.detect { |c| c.name == attr_name.to_s }.scale
          Money.new(x, decimals)
        }
        composed_of attr_name, class_name: "ActsAsMoney::Money", mapping: [attr_name, :amount], 
          allow_nil: true, converter: generator, constructor: generator
      end
    end
  end
end

ActiveRecord::Base.class_eval { include ActsAsMoney }
