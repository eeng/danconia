# Example using BNA (Banco Nación de Argentina) and storing rates daily in ActiveRecord.

require 'danconia/integrations/active_record'
require 'danconia/exchanges/bna'

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

ActiveRecord::Schema.define do
  # You can use this in a Rails migration
  create_table :exchange_rates do |t|
    t.date :date
    t.string :pair, limit: 6
    t.string :rate_type
    t.decimal :rate, precision: 12, scale: 6
    t.index [:date, :pair, :rate_type], unique: true
  end
end

Danconia.configure do |config|
  config.default_exchange = Danconia::Exchanges::BNA.new(
    store: Danconia::Stores::ActiveRecord.new(unique_keys: %i[date pair rate_type])
  )
end

# Periodically call this method to keep the rates up to date
puts 'Updating rates...'
Danconia.config.default_exchange.update_rates!

puts Money(1, 'USD').exchange_to('ARS', rate_type: 'billetes').inspect
puts Money(1, 'USD').exchange_to('ARS', rate_type: 'divisas').inspect
