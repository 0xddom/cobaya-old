module Cobaya
  class BaseContext
    attr_reader :logger
  end
  
  class FuzzingContext < BaseContext
    attr_reader :lang
    attr_reader :crash_handler
    attr_reader :targets
    attr_reader :corpus
    attr_reader :logger

    def initialize(lang, crash_handler, targets, logger, corpus, cpu_aff)
      @lang = lang
      @crash_handler = crash_handler
      @targets = targets
      @logger = logger
      @corpus = corpus
      @cpu_aff = cpu_aff
    end

    def cpu_affinity?
      @cpu_aff
    end

    def cpu_affinity=(cpu_aff)
      @cpu_aff = cpu_aff
    end
  end

  class ExecutableTargetContext < BaseContext
    attr_reader :cmd
    #attr_reader :timeout
    #attr_reader :asan
    #attr_reader :spawn
    #attr_reader :cov
    attr_reader :coverage_index

    def initialize(cmd, logger, cov=true)#, timeout, asan, spawn, cov, sts)
      @logger = logger
      @cmd = cmd
      #@timeout = timeout
      #@asan = asan
      #@spawn = spawn
      @cov = cov
      if cov?
        @coverage_index = Coverage.new
      end
    end

    def cov?
      @cov
    end
  end

  class EvolutionContext < BaseContext
    attr_reader :population

    def initialize(population)
      @population = population
    end
  end
  
  require 'cobaya/context/error'
  require 'cobaya/context/builder'
end
