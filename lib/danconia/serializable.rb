module Danconia
  module Serializable
    def marshal_dump
      {amount: @amount, currency: @currency.code, decimals: @decimals}
    end

    def marshal_load serialized_money
      @amount = serialized_money[:amount]
      @currency = Currency.find(serialized_money[:currency])
      @decimals = serialized_money[:decimals]
    end

    def as_json _options = {}
      {amount: @amount, currency: @currency.code}
    end
  end
end
