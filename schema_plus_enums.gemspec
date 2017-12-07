# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'schema_plus/enums/version'

Gem::Specification.new do |gem|
  gem.name          = "schema_plus_enums"
  gem.version       = SchemaPlus::Enums::VERSION
  gem.authors       = ["ronen barzel"]
  gem.email         = ["ronen@barzel.org"]
  gem.summary       = %q{Adds support for enum data types in ActiveRecord}
  gem.description   = %q{Adds support for enum data types in ActiveRecord}
  gem.homepage      = "https://github.com/SchemaPlus/schema_plus_enums"
  gem.license       = "MIT"

  gem.files         = `git ls-files -z`.split("\x0")
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "activerecord", ">= 4.2", "< 5.2"
  gem.add_dependency "schema_plus_core"
  gem.add_dependency "its-it", "~> 1.2"

  gem.add_development_dependency "bundler", "~> 1.7"
  gem.add_development_dependency "rake", "~> 10.0"
  gem.add_development_dependency "rspec", "~> 3.0"
  gem.add_development_dependency "schema_dev", "~> 3.6"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "simplecov-gem-profile"
end
