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
      View.instance.status 'Breeding'
      @individuals.each do |indv|
        indv.evaluate
        View.instance.step @generation
      end

      avg_len = calculate_avg_len
      avg_fitness = calculate_avg_fitness

      pressure = parsimory_pressure avg_len, avg_fitness
      max = -1
      @individuals.each do |indv|
        indv.fitness.adjust pressure
        score = indv.fitness.score
        max = score if score > max
      end
      max = 1 if max == 0
      
      @individuals.each do |indv|
        indv.fitness.normalize max
        indv.fitness.normalized
      end

      pool = Pool.new @individuals
      @individuals = pool.breed

      @individuals.map! do |indv|
        View.instance.step @generation
        indv.mutate
      end

      @individuals.each(&:trim)
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
      @size.times { |i|
        tree = nil
        max_retries = 10000
        retries = 0
        while tree == nil and retries < max_retries
          begin
            tree = @generator.generate
            @individuals << Individual.new(tree)
          rescue Exception
            View.instance.err "[#{i}] Generation failed. Retrying.#{'.'*retries}\r", newline: false
            #puts e
            #puts e.backtrace
            tree = nil
          end
          retries += 1
        end
        print " " * (retries + 100), "\r"
        if tree.nil?
          $stderr.puts "Couldn't create a tree after #{max_retries} atempts. Aborting..."
          exit! 2
        end
        
      }
      #View.instance.nl
      @generation = 0
    end
    
    def populated?
      @already_populated
    end

    private
    def parsimory_pressure(avg_len, avg_fitness)
      n = @individuals.length - 1
      n = 1 if n <= 0 
      (covariance_f_l(avg_fitness, avg_len) / (n)) *
        ((n) / variance_l(avg_len))
    end

    ##
    # The covariance between the fitness and the length
    def covariance_f_l(avg_fitness, avg_len)
      @individuals.map do |indv|
        d_fitness = indv.fitness.score - avg_fitness
        d_len = indv.fitness.length - avg_len
        d_fitness * d_len
      end.sum
    end

    ##
    # The variance of the length
    def variance_l(avg_len)
      @individuals.map do |indv|
        d_len = indv.fitness.length - avg_len
        d_len ** 2
      end.sum
    end

    def calculate_avg_len
      @individuals.map do |indv|
        indv.fitness.length
      end.sum / @individuals.length
    end

    def calculate_avg_fitness
      @individuals.map do |indv|
        indv.fitness.score
      end.sum / @individuals.length
    end
  end
end
