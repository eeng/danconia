require 'acts_as_money'

module Helpers
  def with_config
    old_config = ActsAsMoney::Config.to_h
    yield ActsAsMoney::Config
    old_config.each { |k, v| ActsAsMoney::Config.send "#{k}=", v }
  end
end

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.include Helpers
end
