require 'danconia'

module Helpers
  def with_config
    old_config = Danconia.config.dup
    yield Danconia.config
    Danconia.config = old_config
  end
end

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.include Helpers
end
