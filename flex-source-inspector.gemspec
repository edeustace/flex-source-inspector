# -*- encoding: utf-8 -*-
require File.expand_path('../lib/flex-source-inspector/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["ed eustace"]
  gem.email         = ["ed.eustace@gmail.com"]
  gem.description   = %q{inspects the source folder of a flex project using 1 or more link-reports and outputs a list of files that aren't in use}
  gem.summary       = %q{inspects the source folder of a flex project using 1 or more link-reports and outputs a list of files that aren't in use}
  gem.homepage      = "https://github.com/edeustace/flex-source-inspector"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "flex-source-inspector"
  gem.require_paths = ["lib"]
  gem.version       = Flex::Source::Inspector::VERSION
  gem.add_development_dependency "rspec", "~> 2.6"
  gem.add_development_dependency "cucumber"
  gem.add_development_dependency "aruba"
  gem.add_dependency "thor"
  
end
