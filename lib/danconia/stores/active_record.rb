module Danconia
  module Stores
    # Simple Store implementation that persist the rates using ActiveRecord.
    # Only stores current rates.
    class ActiveRecord
      def save_rates rates
        ExchangeRate.transaction do
          rates.each do |pair, rate|
            ExchangeRate.where(pair: pair).first_or_initialize.update rate: rate
          end
        end
      end

      def rates
        Hash[ExchangeRate.all.map { |er| [er.pair, er.rate] }]
      end
    end

    class ExchangeRate < ::ActiveRecord::Base
    end
  end
end
