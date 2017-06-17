module Cobaya::Mutators
  class Generative
    def initialize(tree)
      @tree = tree
      @generator = Cobaya::Generators::Ruby19.new
    end

    def mutate
      mutate_tree @tree, 0.2
    end

    private
    def mutate_tree(tree, prob)
      return tree unless tree.class.name == "Parser::AST::Node"
      if (rand < prob) || (tree.leaf? and rand < prob)
        @generator.generate tree.type
      else
        index = rand tree.children.length
        copy = tree.children.dup
        copy[index] = mutate_tree copy[index], prob * 1.5
        tree.updated tree.type, copy
      end
    end
  end
end
