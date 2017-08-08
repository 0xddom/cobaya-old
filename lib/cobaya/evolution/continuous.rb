module Cobaya
  class ContinuousEvolution < BaseEvolution
    def initialize(pop)
      super pop
    end

    def each
      loop do
        indv = population.sample
        new_indv = indv.clone

        # Mutate the new individual
      
        yield new_indv.code, new_indv.fitness

        # Check fitness and add to population if interesting
      end
    end
  end
end
