require 'danconia'

# USD is the default currency if no configuration is provided
puts Money(10.25).inspect # => 10.25 USD

# Lets switch to other currency
Danconia.configure do |config|
  config.default_currency = 'ARS'
end

puts Money(10.25).inspect # => 10.25 ARS
