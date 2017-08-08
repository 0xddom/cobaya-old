module Cobaya
  class Pool
    attr_reader :population

    def initialize(population)
      @population = population
    end

    def breed
      new_pop = []

      (@population.size/2).times do
        indv1, indv2 = [sample, sample]

        new1 = indv1.breed indv2
        new2 = indv2.breed indv1

        new_pop << new1
        new_pop << new2
      end

      new_pop
    end
    
    private
    def sample(n = nil)
      n = @population.size if n.nil?

      while true
        u = rand
        y = @population.sample

        if y.fitness.normalized > u
          return y
        end
      end
    end
  end
end
