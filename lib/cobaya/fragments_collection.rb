require 'singleton'
require 'set'

class FragmentsCollection
  include Singleton

  attr_reader :collection

  def init path, lang
    @collection = Set.new
    @parser = Parsers.get lang
    append path
  end

  def append path
    Dir[File.join(path, "**", "*")].keep_if do |file|
      not File.directory? file
    end.each do |file|
      tree = @parser.parse File.read file
      add_to_set tree
    end
  end

  private
  def add_to_set(tree)
    @collection << tree
    tree.each do |node|
      add_to_set node if node.class.name == "Sexp"
    end
  end
end
