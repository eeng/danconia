require 'active_record'
require 'danconia/stores/active_record'

module Danconia
  module Integrations
    module ActiveRecord
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def money(*attr_names)
          attr_names.each do |attr_name|
            amount_column = attr_name
            currency_column = "#{attr_name}_currency"

            class_eval <<-EOR, __FILE__, __LINE__ + 1
              def #{attr_name}= value
                write_attribute :#{amount_column}, value.is_a?(Money) ? value.amount : value
                write_attribute :#{currency_column}, value.currency.code if respond_to?(:#{currency_column}) && value.is_a?(Money)
              end

              def #{attr_name}
                amount = read_attribute :#{amount_column}
                currency = read_attribute :#{currency_column}
                decimals = self.class.columns.detect { |c| c.name == '#{amount_column}' }.scale
                Money.new amount, currency, decimals: decimals if amount
              end
            EOR
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Danconia::Integrations::ActiveRecord
