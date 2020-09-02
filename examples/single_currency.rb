# Example showing how to use a single currency.

# USD is the default currency if no configuration is provided
puts Money(10.25).inspect # => 5.125 USD

# Lets switch to other currency
Danconia.configure do |config|
  config.default_currency = 'EUR'
  config.available_currencies = [{code: 'EUR', symbol: '€'}]
end

puts Money(10.25).inspect # => 10.25 EUR
puts Money(10.25).to_s # => €10.25
