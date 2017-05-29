module Cobaya
  class Mutation
    
    attr_accessor :tree
    
    def initialize(tree)
      @tree = tree
      @collection = FragmentsCollection.instance
      
      @modify_node_prob = 0.05
      @change_node_prob = 0.2
      @change_self_prob = 1
      @prng = SRandom.instance.prng
    end
    
    def mutate
      mutate_tree tree
    end
    
    def self.from_file(file, language)
      parser = Parsers.get language
      tree = parser.parse File.read file
      
      Mutation.new tree
    end
    
    private
    def mutate_tree(tree)
      return tree unless tree.class.name == "Parser::AST::Node"
      choices = @collection.get_by_type tree.type
      choices[@prng.rand choices.length] if change_self? and choices.length > 0
      if tree.leaf?
        if change? and choices.length > 0
          choices[@prng.rand choices.length]
        else
          tree
        end
      else
        new_children = tree.children.dup
        if mutate?
          new_children.map! do |child|
            if change? and choices.length > 0
              choices[@prng.rand choices.length]
            else
              mutate_tree child
            end
          end
        else
          new_children.map! do |child|
            mutate_tree child
          end
        end
        tree.updated tree.type, new_children
      end
    end
    
    def mutate?
      @prng.rand < @modify_node_prob
    end
    
    def change?
      @prng.rand < @change_node_prob
    end

    def change_self?
      @prng.rand < @change_self_prob
    end
  end
end
