module Helpers
  def with_config &block
    old_config = Danconia.config.dup
    Danconia.configure &block
    Danconia.config = old_config
  end
end
