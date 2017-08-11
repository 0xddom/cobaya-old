require 'rdoc/task'
require 'cobaya/version'
require 'rake/extensiontask'
require 'rake/clean'


RDoc::Task.new do |rdoc|
  version = Cobaya::VERSION

  rdoc.generator = 'hanna'
  rdoc.main = 'README.md'
  rdoc.rdoc_dir = 'doc'

  rdoc.title = "Cobaya #{version} documentation"
  rdoc.rdoc_files.include 'README*'
  rdoc.rdoc_files.include '*.md'
  rdoc.rdoc_files.include File.join 'lib', '**', '*.rb'
end

spec = Gem::Specification.load('cobaya.gemspec')

Gem::PackageTask.new(spec) do |_|
end

Rake::ExtensionTask.new('cobaya/affinity', spec)

CLEAN.include('coverage')
