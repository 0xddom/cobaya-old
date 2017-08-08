# encoding: utf-8
require File.expand_path("../lib/cobaya/version", __FILE__)

Gem::Specification.new do |s|
    #Metadata
    s.name = "cobaya"
    s.version = Cobaya::VERSION
    s.authors = ["Daniel Domínguez"]
    s.email = ["d.domingueza@edu.uah.es"]
    s.homepage = ""
    s.summary = %q{A genetic programming fuzzer for ruby}
    s.description = %q{A genetic programming fuzzer to fuzz ruby interpreters}
    s.licenses = ['MIT']
# If you want to show a post-install message, uncomment the following lines
#    s.post_install_message = <<-MSG
#
#MSG

    #Manifest
    s.files = `git ls-files`.split("\n")
    s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
    s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
    s.require_paths = ['lib']


    s.add_runtime_dependency 'thor', '~> 0.19'
    s.add_runtime_dependency 'parser', '~> 2.3'
    s.add_runtime_dependency 'unparser', '~> 0.2'
    s.add_runtime_dependency 'tty-spinner', '~> 0.4'
    s.add_runtime_dependency 'pastel', '~> 0.7'
    s.add_runtime_dependency 'flog', '~> 4.6'
    s.add_runtime_dependency 'childprocess', '~> 0.7'


    s.add_development_dependency 'rspec', '~> 3'
    s.add_development_dependency 'rdoc', '~> 5.0'
    s.add_development_dependency 'rubycritic', '~> 3.1'
    s.add_development_dependency 'hanna-nouveau', '~> 1.0'
    s.add_development_dependency 'simplecov', '~> 0.14'

end
