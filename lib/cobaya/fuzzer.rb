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
    # Creates a new instance
    def initialize(ctx)
      @ctx = ctx      
    end

    ##
    # Starts the fuzzing loop
    def run
      setup
      fuzzing_loop
    end

    private
    def fuzzing_loop
      for sample, _ in @ctx.corpus
        print '.'
        for target in @ctx.targets
          target.exec sample do |result|
            process_result sample, target, result
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

    def process_result(sample, target, result)
    end
  end
end
