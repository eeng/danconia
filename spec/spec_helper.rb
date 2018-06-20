require 'acts_as_money'

module Helpers
  def with_config
    old_config = ActsAsMoney.config.dup
    yield ActsAsMoney.config
    ActsAsMoney.config = old_config
  end
end

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.include Helpers
end
