module Danconia
  Pair = Struct.new(:from, :to) do
    def self.parse str
      new str[0..2], str[3..-1]
    end

    def invert
      Pair.new to, from
    end

    def to_s
      [from, to].join
    end
  end
end
