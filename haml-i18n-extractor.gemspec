# -*- encoding: utf-8 -*-
require File.expand_path('../lib/haml-i18n-extractor/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Shai Rosenfeld"]
  gem.email         = ["shaiguitar@gmail.com"]
  gem.description   = %q{Parse the texts out of the haml files into localization files}
  gem.summary       = %q{Parse the texts out of the haml files into localization files}
  gem.homepage      = "https://github.com/shaiguitar/haml-i18n-extractor"
  gem.executables = ['haml-i18n-extractor']
  gem.default_executable = 'haml-i18n-extractor'
  gem.license       = 'MIT'
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "haml-i18n-extractor"
  gem.require_paths = ["lib"]
  gem.version       = Haml::I18n::Extractor::VERSION

  gem.add_dependency "tilt"
  gem.add_dependency "haml"
  gem.add_dependency "activesupport"
  gem.add_dependency "highline"
  gem.add_dependency "trollop", "1.16.2"

  gem.add_development_dependency 'rbench'
  gem.add_development_dependency 'm'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'pry-remote'
  gem.add_development_dependency 'pry-nav'
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'nokogiri'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'actionpack'
  gem.add_development_dependency 'rails'

end
