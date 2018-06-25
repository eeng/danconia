require 'danconia'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

ActiveRecord::Schema.define do
  create_table :exchange_rates do |t|
    t.string :pair, limit: 6
    t.decimal :rate, precision: 12, scale: 6
    t.index :pair, unique: true
  end
end

Danconia.configure do |config|
  config.default_exchange = Danconia::Exchanges::CurrencyLayer.new(access_key: ENV['ACCESS_KEY'], store: Danconia::Stores::ActiveRecord.new)
end

# Periodically do this
puts 'Updating dates with CurrencyLayer API...'
Danconia.config.default_exchange.update_rates!

puts Money(1, 'USD').exchange_to('EUR').inspect # => 0.854896 EUR