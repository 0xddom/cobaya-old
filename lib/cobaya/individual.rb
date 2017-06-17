module Cobaya
  module Mutators
    def available
      [Generative]
    end
  end
  
  class Individual < Fragment
    include Cobaya::Mutators
    
    attr_reader :fitness
    
    def initialize(tree)
      super tree
      @fitness = Fitness.new tree
    end

    def evaluate
      @fitness.structure
    end

    def trim
      ruby19 = Cobaya::Generators::Ruby19.new
      trim_tree tree, ruby19.context, ruby19
    end

    ##
    # Returns a new individual with a mutated tree
    def mutate(retries = 0)
      if retries >= 10_000
        $stderr.puts "Couldn't mutate the sample after 10000 retries. Aborting..."
        exit! 2
      end
      begin
        mutator = available.sample.new tree
        Individual.new mutator.mutate
      rescue Exception
        mutate retries + 1
      end
    end

    def breed(other)
      OnePointCrossover.new(self, other).crossover
    end

    private
    def trim_tree(tree, context, generator)
      return tree unless tree.class.name == "Parser::AST::Node"
      if context.max_depth_reached? and context.non_terminal? tree.type
        generator.generate context.terminals.keys.sample
      else
        context.down
        copy = tree.children.dup
        copy.map! do |child|
          trim_tree child, context, generator
        end
        context.up

        tree.updated tree.type, copy
      end
    end
  end
end
