module Cobaya
  ##
  # This class implements a continuous genetic algorithm
  #--
  # TODO:
  # - Send an empty sample if coverage is used to stablish the baseline
  class ContinuousEvolution < BaseEvolution

    ##
    # Creates a new instance of the algorithm
    def initialize(pop)
      super pop
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
      Individual.new Parser::CurrentRuby.parse ctx.population.sample
      new_indv = indv.clone

      # Mutate the new individual
      
      new_indv
    end
  end
end
