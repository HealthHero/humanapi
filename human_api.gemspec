# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'human_api/version'

Gem::Specification.new do |spec|
  spec.name          = "healt_hero-human_api"
  spec.version       = HumanApi::VERSION
  spec.authors       = ["Justin Aiken"]
  spec.email         = ["justin@gohealthhero.com"]
  spec.description   = %q{API client for HumanAPI}
  spec.summary       = %q{API client for HumanAPI}
  spec.homepage      = "https://github.com/HealthHero/humanapi"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "nestful",       "~> 1.0.7"
  spec.add_dependency "json",          "~> 1.8.1"
  spec.add_dependency "activesupport", ">  3.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "dotenv"
  spec.add_development_dependency "pry"
end
