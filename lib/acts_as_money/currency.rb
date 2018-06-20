module ActsAsMoney
  class Currency < Struct.new(:code, :symbol, keyword_init: true)
    def self.[] code
      new Config.available_currencies.find { |c| c[:code] == code } || {code: code, symbol: '$'}
    end
  end
end