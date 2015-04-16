# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mbrowser/version'

Gem::Specification.new do |spec|
  spec.name          = 'mbrowser'
  spec.version       = Mbrowser::VERSION
  spec.authors       = ['lvpython']
  spec.email         = ['lvpython@gmail.com']
  spec.description   = 'mbrowser'
  spec.summary       = 'mbrowser'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 1.3'
  spec.add_development_dependency 'rake'
  spec.add_dependency 'curb', '>= 0.8.3'
  spec.add_dependency 'nokogiri', '>= 1.6.0'
end
