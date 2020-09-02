module Danconia
  module Stores
    # Store implementation that persist rates using ActiveRecord.
    class ActiveRecord
      def initialize unique_keys: %i[pair]
        @unique_keys = unique_keys
      end

      # Creates or updates the rates by the `unique_keys` provided in the constructor.
      #
      # @param rates [Array] must be an array of maps.
      def save_rates rates
        ExchangeRate.transaction do
          rates.each do |fields|
            ExchangeRate
              .where(fields.slice(*@unique_keys))
              .first_or_initialize
              .update(fields.slice(*ExchangeRate.column_names.map(&:to_sym)))
          end
        end
      end

      # Returns an array of maps like the one it received.
      def rates **filters
        ExchangeRate.where(filters).map { |er| er.attributes.symbolize_keys }
      end
    end

    class ExchangeRate < ::ActiveRecord::Base
    end
  end
end
