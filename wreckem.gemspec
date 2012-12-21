# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "wreckem/version"

Gem::Specification.new do |s|
  s.name        = 'wreckem'
  s.version     = Wreckem::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = 'Thomas E. Enebo'
  s.email       = 'tom.enebo@gmail.com'
  s.homepage    = 'http://github.com/enebo/wreckem'
  s.summary     = '(R)uby (E)ntity (C)omponent (M)odelling framework'
  s.description = '(R)uby (E)ntity (C)omponent (M)odelling framework'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.has_rdoc      = true
end
