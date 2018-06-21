# RSpec uses a custom inspector for delegator objects so without this the failure messages are confussing for Money objects.
require 'rspec/support/object_formatter'
RSpec::Support::ObjectFormatter::INSPECTOR_CLASSES.delete RSpec::Support::ObjectFormatter::DelegatorInspector
