module Danconia
  module Errors
    class ExchangeRateNotFound < StandardError
      def initialize src, dst
        super "No exchange rate found from #{src} to #{dst}"
      end
    end
  end
end