# encoding: utf-8
require File.expand_path("../lib/cobaya/version", __FILE__)

Gem::Specification.new do |s|
    #Metadata
    s.name = "cobaya"
    s.version = Cobaya::VERSION
    s.authors = ["Kuro"]
    s.email = ["danieldominguez05@gmail.com"]
    s.homepage = ""
    s.summary = %q{A genetic programming fuzzer for ruby}
    s.description = %q{A genetic programing fuzzer to fuzz ruby interpreters}
    s.licenses = ['']
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
    
    
    s.add_development_dependency 'rspec', '~> 3'
    
end
