# Danconia

A very simple money library for Ruby, backed by BigDecimal, with multi-currency support.

[![Build Status](https://travis-ci.org/eeng/danconia.svg?branch=master)](https://travis-ci.org/eeng/danconia)

## Features

* Backed by BigDecimal (no conversion to cents is done, i.e. "infinite precision")
* Multi-currency support
* Pluggable exchange rates services:
  - [CurrencyLayer API](https://currencylayer.com/)
  - [BNA](https://www.bna.com.ar/)
  - FixedRates (for testing use)
* Pluggable stores for persisting the exchange rates

## Installation

```ruby
gem 'danconia'
```

## Basic Usage

If you only need to work with a single currency:

```ruby
# USD by default, but can be configured
m1 = Money(10.25) # => 10.25 USD

# Note that we keep all decimal places
m2 = m1 / 2 # => 5.125 USD

# Simple formatting by default
puts m2 # => $5.13
```

Please refer to `examples/single_currency.rb` for some configuration options.

## Multi-Currency Support

To handle multiple currencies you need to configure an `Exchange` in order to fetch the rates. For example, with CurrencyLayer:

```ruby
# This can be placed in a Rails initializer
require 'danconia/exchanges/currency_layer'

Danconia.configure do |config|
  config.default_exchange = Danconia::Exchanges::CurrencyLayer.new(access_key: '...')
end
```

Then, download the exchange rates:
```ruby
# You should do this periodically to keep rates up to date
Danconia.config.default_exchange.update_rates!
```

And finally to convert between currencies:
```ruby
Money(9, 'JPY').exchange_to('ARS') # => 2.272401 ARS
```

By default, rates are stored in memory, but you can supply a store in the exchange constructor to save them elsewhere. Please refer to `examples/currency_layer.rb` for an ActiveRecord example.

## Active Record Integration

Given a `products` table with a decimal column `price` and a string column `price_currency` (optional), then you can use the `money` class method to automatically convert it to Money:

```ruby
require 'danconia/integrations/active_record'

class Product < ActiveRecord::Base
  money :price
end

Product.new(price: 30, price_currency: 'ARS').price # => 30 ARS
```

Currently, there is no option to customize the names of the columns but should be fairly simple to implement if needed.

## Testing

There is a FixedRates exchange that can be used during testing to supply static rates (see `examples/fixed_rates.rb`). Another possibility is to use the following helper:

```ruby
require 'danconia/test_helpers'

Danconia::TestHelpers.with_rates 'USDARS' => 3 do
  Money(2, 'USD').exchange_to('ARS') # => 6.0 ARS
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
