# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acts_as_money/version'

Gem::Specification.new do |gem|
  gem.name          = "eeng-money"
  gem.version       = ActsAsMoney::VERSION
  gem.authors       = ["Emmanuel Nicolau"]
  gem.email         = ["emmanicolau@gmail.com"]
  gem.description   = %q{Single currency money backed by BigDecimal}
  gem.summary       = %q{Single currency money backed by BigDecimal}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency "activerecord", '>= 3.0.0'
  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "guard"
  gem.add_development_dependency "guard-minitest"
end
