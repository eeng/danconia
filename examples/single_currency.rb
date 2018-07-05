require 'danconia'

Danconia.configure do |config|
  config.default_currency = 'ARS'
end

puts Money(10.25).inspect # => 10.25 ARS