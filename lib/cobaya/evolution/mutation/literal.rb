module Cobaya::Mutation
  module LiteralMutation
    
    def self.mutate(input)
      unless input.is_a? Parser::AST::Node
        return input
      end
      r = rand
      if Cobaya::LiteralGenerator.literal? input.type and r < prob
        Cobaya::LiteralGenerator.random.generate
      else
        input.updated(input.type, input.children.map {|c| mutate c})
      end
    end

    private

    def self.prob
      0.2
    end
  end
end
