# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'giraph/version'

Gem::Specification.new do |spec|
  spec.name          = 'giraph'
  spec.version       = Giraph::VERSION
  spec.authors       = ['Erman Celen']
  spec.email         = ['erman@upserve.com']

  spec.summary       = 'Composable GraphQL for micro-services'
  spec.description   = 'Expose a remote GraphQL endpoint within another as a regular field'
  spec.homepage      = 'https://github.com/upserve/giraph'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.1'

  spec.add_runtime_dependency 'graphql', '~> 0.15.3'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
