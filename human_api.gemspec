# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'human_api/version'

Gem::Specification.new do |spec|
  spec.name          = "human_api"
  spec.version       = HumanApi::VERSION
  spec.authors       = ["Alessio Santo"]
  spec.email         = ["alessio.santo@pazienti.it"]
  spec.description   = %q{API client for HumanAPI}
  spec.summary       = %q{API client for HumanAPI}
  spec.homepage      = "https://github.com/Pazienti/humanapi"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "nestful", "~> 1.0.4"
  spec.add_dependency "json", "~> 1.8.1"


  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
