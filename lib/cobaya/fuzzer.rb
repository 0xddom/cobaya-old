class Integer
  N_BYTES = [42].pack('i').size
  N_BITS = N_BYTES * 16
  MAX = 2 ** (N_BITS - 2) - 1
  MIN = -MAX - 1
end

module Cobaya
  class Fuzzer
    def initialize(target, crashes, inputs, lang)
      @view = View.new
      @collection = FragmentsCollection.instance
      @target = target
      @crashes = crashes
      @lang = lang
      @inputs = inputs
    end


    
    def run
      @view.banner

      setup

      @view.ok 'Fuzzer ready'
      loop do
        @current_sample_file = File.open '/tmp/cobaya_current_sample.rb', 'w'

        prepare_next_sample
        @current_sample_file.close

        executor = StdinExecutor.new @current_sample_file.path, @target, @crashes
        result = executor.execute

        if result
          @view.log_crash result
        else
          @view.step
        end
        

        @rounds = @rounds + 1
      end
    end

    private
    def prepare_next_sample
      sample = @inputs[@prng.rand @inputs.length]
      mutation = Mutation.from_file sample, @lang
      mutated_sample = mutation.mutate
      fragment = Fragment.new mutated_sample, @current_sample_file.path
      fragment.write_to_io @current_sample_file
    end

    def setup
      @view.info "Loading input files from #{@inputs}"
      @inputs = Dir[File.join @inputs, '**', '*'].keep_if { |file| not File.directory? file }

      raise "No inputs!" if @inputs.length == 0
      
      seed = Time.now.to_i
      @view.info "Using #{seed} as initial seed"
      SRandom.instance.init seed
      
      @prng = SRandom.instance.prng

      @current_sample_file = nil
      @rounds = 0
    end
  end
end
