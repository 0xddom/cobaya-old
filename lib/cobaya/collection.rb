module Cobaya
  class FragmentsCollection
    include Singleton
    
    attr_reader :collection
    
    def init path, lang
      @collection = Set.new
      @parser = Parsers.get lang
      @lookup = {}
      @valid_cache = true
      append path
    end
    
    def append path
      Dir[File.join(path, "**", "*")].keep_if do |file|
        not File.directory? file
      end.each do |file|
        tree = @parser.parse File.read file
        add_to_set tree
      end
      @valid_cache = false
    end
    
    def get_by_type(type)
      @lookup = {} unless @valid_cache
      @lookup[type] || @lookup[type] = collect_by_type(type)
    end
    
    private
    def add_to_set(tree)
      @collection << tree
      tree.children.each do |node|
        add_to_set node if node.class.name == "Parser::AST::Node"
      end
    end
    
    def collect_by_type(type)
      @collection.to_a.keep_if do |node|
        node.type == type
      end
    end
  end
end
