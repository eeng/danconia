module Danconia
  module Stores
    # Store implementation that persist the latest rates using ActiveRecord.
    class ActiveRecord
      def initialize unique_keys: %i[pair]
        @unique_keys = unique_keys
      end

      # Creates or updates the current rates.
      #
      # @param rates [Array] must be an array of maps containing the `unique_keys` provided in the constructor.
      def save_rates rates
        ExchangeRate.transaction do
          rates.each do |fields|
            ExchangeRate.where(fields.slice(*@unique_keys)).first_or_initialize.update(fields)
          end
        end
      end

      # Returns an array of maps like the one it received.
      def rates **_opts
        ExchangeRate.all.map { |er| er.attributes.symbolize_keys }
      end
    end

    class ExchangeRate < ::ActiveRecord::Base
    end
  end
end
