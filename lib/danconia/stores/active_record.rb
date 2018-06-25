module Danconia
  module Stores
    class ActiveRecord
      def save_rates rates
        ExchangeRate.transaction do
          rates.each do |pair, rate|
            ExchangeRate.where(pair: pair).first_or_initialize.update rate: rate
          end
        end
      end

      def direct_rate from, to
        ExchangeRate.find_by(pair: [from, to].join)&.rate
      end

      def rates
        ExchangeRate.all
      end
    end

    class ExchangeRate < ::ActiveRecord::Base
    end
  end
end
