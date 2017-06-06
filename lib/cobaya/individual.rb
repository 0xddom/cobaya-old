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

    ##
    # Returns a new individual with a mutated tree
    def mutate
      mutator = available.sample.new tree
      Individual.new mutator.mutate
    end
  end
end
