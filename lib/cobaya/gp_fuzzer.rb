module Cobaya
  class GPFuzzer
    def initialize(target, crashes)
      @view = View.new
      @target = target
      @crashes = crashes
      @population = Population.new
    end

    def run
      @view.banner
      setup
      @view.ok 'Fuzzer ready'
      loop do
        @population.individuals.each do |indv|
          
          output_file = File.open '/tmp/current_sample_file.rb', 'w'
          indv.write_to_io output_file
          output_file.close

          executor = StdinExecutor.new output_file.path, @target, @crashes
          result = executor.execute

          if result
            @view.log_crash result
          else
            @view.step
          end
        end
        @view.info "New generation"
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
