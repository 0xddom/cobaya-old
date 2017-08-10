class Integer
  N_BYTES = [42].pack('i').size
  N_BITS = N_BYTES * 16
  MAX = 2 ** (N_BITS - 2) - 1
  MIN = -MAX - 1
end

module Cobaya

  ##
  # This class handles the fuzzing loop
  class Fuzzer

    ##
    # The amount of crashes found by the fuzzer
    attr_reader :crashes
    
    ##
    # Creates a new instance
    def initialize(ctx)
      @ctx = ctx
      @crashes = 0
    end

    ##
    # Starts the fuzzing loop
    def run
      setup
      fuzzing_loop
    end

    private
    def fuzzing_loop
      for sample, fitness in @ctx.corpus
        print '.'
        for target in @ctx.targets
          target.exec sample do |result|
            process_result sample, target, result, fitness
          end
        end
      end
    end

#    def prepare_next_sample
#      sample = @inputs[@prng.rand @inputs.length]
#      mutation = Mutation.from_file sample, @lang
#      mutated_sample = mutation.mutate
#      fragment = Fragment.new mutated_sample, @current_sample_file.path
#      fragment.write_to_io @current_sample_file
#    end

    def setup
    end

    def process_result(sample, target, result, fitness)
      if result.crash?
        @crashes += 1
        @ctx.crash_handler << sample
      end

      if fitness.interesting?
        @ctx.corpus << sample
      end
    end
  end
end
