# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bongloy/spec_helpers/version'

Gem::Specification.new do |spec|
  spec.name          = "bongloy-spec-helpers"
  spec.version       = Bongloy::SpecHelpers::VERSION
  spec.authors       = ["David Wilkie"]
  spec.email         = ["dwilkie@gmail.com"]
  spec.description   = %q{Common spec helpers and support files used accross Bongloy apps}
  spec.summary       = %q{Common spec helpers and support files used accross Bongloy apps}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "webmock"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "dotenv"
end
