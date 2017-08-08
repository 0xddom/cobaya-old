require 'rdoc/task'
require 'cobaya/version'

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
