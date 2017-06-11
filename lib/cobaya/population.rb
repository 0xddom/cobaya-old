module Cobaya
  class Population
    attr_reader :individuals, :size, :generation
    
    def initialize(directory, pop_size = 100)
      @already_populated = false
      @generator = Cobaya::Generators::Ruby19.new
      @size = pop_size
      @individuals = []
      @generation = 0
      @directory = directory
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

    def save
      save_dir = File.join @directory, @generation.to_s
      Dir.mkdir save_dir unless Dir.exist? save_dir
      @individuals.each_index do |i|
        indv_save_file = File.join save_dir, "#{i}.rb"
        file = File.open indv_save_file, 'w'
        @individuals[i].write_to_io file
        file.close
      end
    end
    
    def reset
      @individuals = []
      @size.times {
        tree = nil
        while tree == nil
          begin
            tree = @generator.generate
          #rescue Exception => e
#            View.instance.err "Generation failed. Retrying..."
#            puts e
#            puts e.backtrace
#            tree = nil
          end
        end
        @individuals << Individual.new(tree)
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
