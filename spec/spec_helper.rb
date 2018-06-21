require 'danconia'

Dir["#{__dir__}/support/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.include Helpers
end
