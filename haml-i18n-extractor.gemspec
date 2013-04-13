# -*- encoding: utf-8 -*-
require File.expand_path('../lib/haml-i18n-extractor/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Shai Rosenfeld"]
  gem.email         = ["shaiguitar@gmail.com"]
  gem.description   = %q{Parse the texts out of the haml files into localization files}
  gem.summary       = %q{Parse the texts out of the haml files into localization files}
  gem.homepage      = ""
  gem.executables = ['haml-i18n-extractor']
  gem.default_executable = 'haml-i18n-extractor'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "haml-i18n-extractor"
  gem.require_paths = ["lib"]
  gem.version       = Haml::I18n::Extractor::VERSION

  gem.add_dependency "tilt"
  gem.add_dependency "haml"

  gem.add_development_dependency 'rails', '>= 3.0.0'
  gem.add_development_dependency 'rbench'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'nokogiri'
  gem.add_development_dependency 'highline'

end
