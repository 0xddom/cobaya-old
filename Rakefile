require 'rdoc/task'
require 'cobaya/version'
require 'rake/extensiontask'
require 'rake/clean'
require "rubycritic/rake_task"


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

RubyCritic::RakeTask.new do |task|
  task.paths = FileList['lib/cobaya/**/*.rb']
  task.options = '--no-browser'
end

namespace :manual do
  task :build do
    Dir.chdir 'manual'
    sh 'gitbook build'
  end

  task :pdf do
    sh "gitbook pdf ./manual Cobaya_User_manual_#{Cobaya::VERSION}.pdf"
  end
end
CLEAN.include('**/*.pdf')
CLEAN.include('manual/_book')
