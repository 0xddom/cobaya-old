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

    def self.from_file(file, language = :ruby19)
      parser = Cobaya::Parsers.get language
      tree = parser.parse File.read file
      Individual.new tree
    end

    def self.from_str(str, language = :ruby19)
      parser = Cobata::Parsers.get language
      tree = parser.parse str
      Individual.new tree
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
    def trim_tree(tree, context, generator, retries = 0)
      if retries >= 10_000
        $stderr.puts "Couldn't trim the sample after 10000 retries. Aborting..."
        exit! 2
      end
      return tree unless tree.class.name == "Parser::AST::Node"
      if context.max_depth_reached? and context.non_terminal? tree.type
        begin
          generator.generate context.terminals.keys.sample
        rescue Exception
          trim_tree tree, context, generator, retries + 1
        end
      else
        context.down
        copy = tree.children.dup
        copy.map! do |child|
          trim_tree child, context, generator, retries
        end
        context.up

        tree.updated tree.type, copy
      end
    end
  end
end
