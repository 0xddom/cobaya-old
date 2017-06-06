module Cobaya
  class Population
    attr_reader :individuals, :size
    
    def initialize(pop_size = 100)
      @already_populated = false
      @generator = Cobaya::Generators::Ruby19.new
      @size = pop_size
      @individuals = []
      @generations = 0
    end

    def populate
      unless populated?
        reset
        @already_populated = true
      end
    end

    def reset
      @size.times {
        @individuals << Individual.new(@generator.generate)
      }
      @generations = 0
    end
    
    def populated?
      @already_populated
    end

    
  end
end
