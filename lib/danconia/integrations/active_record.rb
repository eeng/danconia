require 'active_record'

module Danconia
  module Integrations
    module ActiveRecord
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def money(*attr_names)
          attr_names.each do |attr_name|
            class_eval <<-EOR, __FILE__, __LINE__ + 1
              def #{attr_name}= value
                if respond_to? :#{attr_name}_currency
                  write_attribute :#{attr_name}_amount, (value.is_a?(Money) ? value.amount : value)
                  write_attribute :#{attr_name}_currency, (value.is_a?(Money) ? value.currency.code : nil)
                else
                  write_attribute :#{attr_name}, (value.is_a?(Money) ? value.amount : value)
                end
              end

              def #{attr_name}
                amount_column, currency_column = if respond_to? :#{attr_name}_currency
                  [:#{attr_name}_amount, :#{attr_name}_currency]
                else
                  [:#{attr_name}, nil]
                end
                amount = read_attribute amount_column
                currency = read_attribute currency_column
                decimals = self.class.columns.detect { |c| c.name == amount_column.to_s }.scale
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
