# Example using CurrencyLayer API and storing only the latests rates in ActiveRecord.
# Remember to supply your CurrencyLayer key in the ACCESS_KEY environment variable to run this example

require 'danconia/integrations/active_record'
require 'danconia/exchanges/currency_layer'

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

ActiveRecord::Schema.define do
  # You can use this in a Rails migration
  create_table :exchange_rates do |t|
    t.string :pair, limit: 6
    t.decimal :rate, precision: 12, scale: 6
    t.index :pair, unique: true
  end
end

Danconia.configure do |config|
  config.default_exchange = Danconia::Exchanges::CurrencyLayer.new(
    access_key: ENV['ACCESS_KEY'],
    store: Danconia::Stores::ActiveRecord.new
  )
end

# Periodically call this method to keep the rates up to date
puts 'Updating rates...'
Danconia.config.default_exchange.update_rates!

puts Money(1, 'USD').exchange_to('EUR').inspect # => 0.854896 EUR
