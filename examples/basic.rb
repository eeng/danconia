require 'danconia'

Danconia.configure do |config|
  config.default_currency = 'ARS'
  config.default_exchange = Danconia::Exchanges::FixedRates.new(rates: {'USDARS' => 27.5, 'USDEUR' => 0.86})
end

puts Money(10, 'ARS').exchange_to('EUR').inspect