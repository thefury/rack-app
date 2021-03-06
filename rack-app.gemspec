# coding: utf-8
# lib = File.expand_path('../lib', __FILE__)
# $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
# require 'rack/app/version'

Gem::Specification.new do |spec|

  spec.name          = "rack-app"
  spec.version       = File.read(File.join(File.dirname(__FILE__), 'VERSION')).strip
  spec.authors       = ["Adam Luzsi","Daniel Nagy"]
  spec.email         = ["adamluzsi@gmail.com","naitodai@gmail.com"]

  spec.summary       = %q{Your next favourite, performance designed micro framework!}
  spec.description   = %q{Your next favourite rack based micro framework that is totally addition free! Have a cup of awesomeness with  your to performance designed framework!}
  spec.homepage      = 'https://github.com/rack-app'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.license       = 'GNU General Public License v3'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_dependency "rack"

end
