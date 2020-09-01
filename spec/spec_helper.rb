require 'danconia'
require 'danconia/test_helpers'
require 'danconia/integrations/active_record'
require 'webmock/rspec'

Dir["#{__dir__}/support/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.include DatabaseCleaner
end
