module Danconia
  Currency = Struct.new(:code, :symbol, :description, keyword_init: true) do
    def self.find code
      return code if code.is_a? Currency
      new Danconia.config.available_currencies.find { |c| c[:code] == code } || {code: code, symbol: '$'}
    end
  end
end
