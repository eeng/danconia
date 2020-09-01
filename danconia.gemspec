# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'danconia/version'

Gem::Specification.new do |gem|
  gem.name          = "danconia"
  gem.version       = Danconia::VERSION
  gem.author        = "Emmanuel Nicolau"
  gem.email         = "emmanicolau@gmail.com"
  gem.description   = %q{Multi-currency money library backed by BigDecimal}
  gem.summary       = %q{Multi-currency money library backed by BigDecimal}
  gem.homepage      = "https://github.com/eeng/danconia"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'activesupport', '>= 4.0'
  gem.add_development_dependency "activerecord", '>= 4.0'
  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "guard"
  gem.add_development_dependency "guard-rspec"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "webmock"
  gem.add_development_dependency "nokogiri"
  gem.add_development_dependency 'rubocop', '~> 0.80.0'
end
