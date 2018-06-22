module Danconia
  class BasicExchange
    def initialize &block
      @block = block
    end

    def rate from, to
      return 1 if from == to
      @block.call from, to if @block
    end

    def available_currencies
      []
    end
  end
end
