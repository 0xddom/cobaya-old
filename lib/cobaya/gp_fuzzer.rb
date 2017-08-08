module Cobaya
  ##
  # Deprecated
  class GPFuzzer
    def initialize(target, crashes, population, size)
      @view = View.instance
      @target = target
      @crashes = crashes
      @population = Population.new population, size
    end

    def run
      @view.banner
      setup
      @view.ok 'Fuzzer ready'
      loop do
        @population.save
        @view.status 'Fuzzing'
        @population.individuals.each do |indv|
          
          fitness = indv.fitness
          
          output_file = File.open "/tmp/sample_file_#{Time.now.to_i}_#{rand(Time.now.to_i).to_i}.rb", 'w'
          indv.write_to_io output_file
          output_file.close

          executor = StdinExecutor.new output_file.path, @target, @crashes
          cov, result = executor.execute

          if result
            #@view.nl.log_crash result
          else
            @view.step @population.generation
          end

          fitness.feedback cov, result
        end
        @view.nl
        @population.breed
        @view.nl
      end
    end

    def setup
      @view.info "Creating the initial population (#{@population.size} individuals)"
      @population.populate
      seed = Time.now.to_i
      @view.info "Using #{seed} as initial seed"
      srand seed
    end
  end
end
