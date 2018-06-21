module Helpers
  def with_config
    old_config = Danconia.config.dup
    yield Danconia.config
    Danconia.config = old_config
  end
end
