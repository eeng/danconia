module Danconia
  class Currency < Struct.new(:code, :symbol, :description, keyword_init: true)
    def self.[] code
      new Danconia.config.available_currencies.find { |c| c[:code] == code } || {code: code, symbol: '$'}
    end
  end
end