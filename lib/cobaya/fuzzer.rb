##
# Deprecated?
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
        for target in @ctx.targets
          @ctx.logger.debug { "Sample sent" }
          target.exec sample do |result|
            process_result sample, target, result, fitness
          end
        end
      end
    end

    def setup
      if @ctx.cpu_affinity?
        begin
          @ctx.logger.info "Try setting the affinity to an available CPU"
          @ctx.cpu = Affinity.choose_available_cpu
        rescue Affinity::CPUNotSetError => _
          @ctx.cpu_affinity = false
          @ctx.logger.warn "The affinity was not set. Probably you are running to much instances of cobaya or other CPU heavy process"
        rescue Affinity::UnsupportedPlatformError
          @ctx.cpu_affinity = false
          @ctx.logger.warn "The current platform doesn't support CPU affinity"
        end
      else
        @ctx.logger.info "Not setting the CPU affinity"
      end
    end

    def process_result(sample, target, result, fitness)
      if result.crash?
        @crashes += 1
        @ctx.crash_handler << sample
        @ctx.logger.info "Found a crash!"
      end

      if fitness.interesting?
        @ctx.corpus << sample
        @ctx.logger.info "Added an interesting sample to the corpus"
      end

    end
  end
end
