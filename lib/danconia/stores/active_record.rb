module Danconia
  module Stores
    # Store implementation that persist rates using ActiveRecord.
    class ActiveRecord
      # @param unique_keys [Array] each save_rates will update records with this keys' values
      # @param date_field [Symbol] used when storing daily rates
      def initialize unique_keys: %i[pair], date_field: nil
        @unique_keys = unique_keys
        @date_field = date_field
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
        ExchangeRate.where(process_filters(filters)).map { |er| er.attributes.symbolize_keys }
      end

      private

      def process_filters filters
        if @date_field
          param = filters.delete(@date_field) || Date.today
          last_record = ExchangeRate.where(filters).where("#{@date_field} <= ?", param).order(@date_field => :desc).first
          filters.merge(@date_field => (last_record[@date_field] if last_record))
        else
          filters
        end
      end
    end

    class ExchangeRate < ::ActiveRecord::Base
    end
  end
end
