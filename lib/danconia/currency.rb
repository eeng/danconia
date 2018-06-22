module Danconia
  class Currency < Struct.new(:code, :symbol, :description, keyword_init: true)
    def self.find code, exchange
      return code if code.is_a? Currency
      new exchange.currencies.find { |c| c[:code] == code } || {code: code, symbol: '$'}
    end
  end
end