module Cobaya
  class Population
    attr_reader :individuals, :size, :generation
    
    def initialize(pop_size = 100)
      @already_populated = false
      @generator = Cobaya::Generators::Ruby19.new
      @size = pop_size
      @individuals = []
      @generation = 0
    end

    def populate
      unless populated?
        reset
        @already_populated = true
      end
    end

    def breed
      @individuals.each do |indv|
        indv.evaluate
      end
      
      @individuals.map! do |indv|
        indv.mutate
      end
      @generation += 1
    end
    
    def reset
      @size.times {
        @individuals << Individual.new(@generator.generate)
      }
      @generation = 0
    end
    
    def populated?
      @already_populated
    end

    private
    def parsimory_pressure
      (covariance_f_l / (n-1)) * ((n-1) / variance_l)
    end

    ##
    # The covariance between the fitness and the length
    def covariance_f_l
      raise "TODO"
    end

    ##
    # The variance of the length
    def variance_l
      raise "TODO"
    end
  end
end
