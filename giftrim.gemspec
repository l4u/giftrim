# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'giftrim/version'

Gem::Specification.new do |spec|
  spec.name          = "giftrim"
  spec.version       = Giftrim::VERSION
  spec.authors       = ["Leo Lou"]
  spec.email         = ["louyuhong@gmail.com"]
  spec.description   = "GIF optimizations using gifsicle"
  spec.summary       = "GIF optimizations using gifsicle "
  spec.homepage      = "https://github.com/l4u/giftrim"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency("simplecov", "~> 0.7")
  spec.add_development_dependency("simplecov-gem-adapter", "~> 1.0.1")
  spec.add_runtime_dependency("subexec", ["~> 0.2.2"])


end
