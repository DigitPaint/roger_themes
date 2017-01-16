# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "roger_themes/version"

Gem::Specification.new do |spec|
  spec.name          = "roger_themes"
  spec.version       = RogerThemes::VERSION
  spec.authors       = ["Edwin van der Graaf", "Flurin Egger"]
  spec.email         = ["edwin@digitpaint.nl", "flurin@digitpaint.nl"]
  spec.summary       = "Create themes and release them as static site"
  spec.homepage      = "https://github.com/digitpaint/roger_themes"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "roger", "~> 1.0", ">= 1.7.0"
  spec.add_dependency "rack"

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "test-unit", "~> 3.1.2"
  spec.add_development_dependency "simplecov", "~> 0.10.0"
  spec.add_development_dependency "rubocop", "~> 0.31.0"
end
