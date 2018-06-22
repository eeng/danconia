require 'danconia'
require 'webmock/rspec'

Dir["#{__dir__}/support/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.include Helpers
  config.include DatabaseCleaner
end
