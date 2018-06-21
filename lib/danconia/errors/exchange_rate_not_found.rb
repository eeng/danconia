module Danconia
  module Errors
    class ExchangeRateNotFound < StandardError
      def initialize src, dst
        super "No exchange rate found between currencies #{src} and #{dst}"
      end
    end
  end
end