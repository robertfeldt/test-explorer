# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'test-explorer/version'

Gem::Specification.new do |gem|
  gem.name          = "test-explorer"
  gem.version       = TestExplorer::VERSION
  gem.authors       = ["Robert Feldt"]
  gem.email         = ["robert.feldt@gmail.com"]
  gem.description   = <<-EOS
    TestExplorer automatically searches for tests for your Ruby code. You
    inspect the tests it finds and can add them to your test suite. It cuts
    down on test development time, finds good tests and is a lot of fun. :)
    Come join and put those wasted CPU cycles to some good testing use!
  EOS
  gem.summary       = %q{explore good tests for your Ruby code}
  gem.homepage      = "http://github.com/robertfeldt/test-explorer"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
