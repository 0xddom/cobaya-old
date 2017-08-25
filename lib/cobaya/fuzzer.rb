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
          @ctx.logger.warn "The affinity couldn't be set. Probably you are running to much instances of cobaya or other CPU heavy process"
        rescue Affinity::UnsupportedPlatformError
          @ctx.cpu_affinity = false
          @ctx.logger.warn "The current platform doesn't support CPU affinity"
        end
      else
        @ctx.logger.info "Not setting the CPU affinity"
      end

      if true # Replace with a check if the evolution strategy uses coverage
        @ctx.logger.info "Setting the baseline coverage information"
        for target in @ctx.targets
          if target.ctx.cov?
            target.exec '' do |result|
              process_cov_baseline target, result
            end
          end
        end
      end
    end

    def process_cov_baseline(target, result)
      if result.crash?
        @ctx.logger.error "The target crashed with an empty input. This is probably a bug."
        return
      end
      
      unless result.meta.has_key? :cov
        raise ArgumentError.new 'The metadata in result must have a cov key'
      end

      target.coverage_index.add result.meta[:cov].addresses
    end
    
    def process_result(sample, target, result, fitness)
      @ctx.logger.debug(result.meta)
      
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
