module Cobaya
  ##
  # This class implements a continuous genetic algorithm
  #--
  # TODO:
  # - Add crossovers
  class ContinuousEvolution < BaseEvolution

    ##
    # Creates a new instance of the algorithm
    def initialize(ctx)
      super ctx
    end

    ##
    # Yields random elements of the population to be tested
    def each
      loop do
        indv = generate_new_indv      
        yield indv.code, indv.fitness
        if indv.fitness.interesting?
          ctx.population << indv.code
        end
      end
    end

    private
    def generate_new_indv
      indv = Individual.from_str ctx.population.sample
      new_tree = mutations.sample.mutate indv.tree
      
      Individual.new new_tree
    end
  end
end
