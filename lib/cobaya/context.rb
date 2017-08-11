module Cobaya
  class BaseContext
    #attr_accessor :logger
  end
  
  class FuzzingContext < BaseContext
    #attr_reader :lang
    attr_reader :crash_handler
    attr_reader :targets
    attr_reader :corpus
    attr_reader :workers

    attr_accessor :cpu

    def initialize(crashes, target, corpus, cpu_aff)
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

    def initialize(cmd)#, timeout, asan, spawn, cov, sts)
      @cmd = cmd
      #@timeout = timeout
      #@asan = asan
      #@spawn = spawn
      #@cov = cov
    end
  end

  require 'cobaya/context/error'
  require 'cobaya/context/builder'
end
