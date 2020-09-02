require 'danconia/pair'

module Danconia
  class Exchange
    def rate from, to, **opts
      return 1.0 if from == to

      pair = Pair.new(from, to)
      rates = direct_and_inverted_rates(opts)
      rates[pair] or indirect_rate(pair, rates) or raise Errors::ExchangeRateNotFound.new(from, to)
    end

    # Override this method in subclasses. Should return a map of pairs to rates.
    # See `FixedRates` for an example implementation.
    def rates **_opts
      raise NotImplementedError
    end

    private

    # Returns the original rates plus the inverted ones, to simplify rate finding logic.
    # Also wraps the pair strings into Pair objects.
    def direct_and_inverted_rates opts
      rates(opts).each_with_object({}) do |(pair_str, rate), rs|
        pair = Pair.parse(pair_str)
        rs[pair] = rate
        rs[pair.invert] ||= 1.0 / rate
      end
    end

    def indirect_rate ind_pair, rates
      if (from_pair = rates.keys.detect { |pair| pair.from == ind_pair.from }) &&
         (to_pair = rates.keys.detect { |pair| pair.to == ind_pair.to })
        rates[from_pair] * rates[to_pair]
      end
    end
  end
end
