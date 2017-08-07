module Cobaya

  class FuzzingContext
    attr_reader :lang
    attr_reader :crash_handler
    attr_reader :target
    attr_reader :logger
    attr_reader :population
    attr_reader :workers

    def initialize(lang, crash_handler, target, logger, population, workers)
      @lang = lang
      @crash_handler = crash_handler
      @target = target
      @logger = logger
      @population = population
      @workers = workers
    end
  end

  class ContextBuildError < RuntimeError
    attr_reader :errors
    
    def initialize
      @errors = []
    end

    def any?
      !@errors.empty?
    end
  end

  class FuzzingContextBuilder
    attr_reader :ctx
    
    def initialize
      @ctx = nil
      @error = ContextBuildError.new


      @population = []
      @workers = 1
    end

    def build
      check_errors
      @ctx = FuzzingContext.new(@lang,
                                @crash_handler,
                                @target,
                                @logger,
                                @population,
                                @workers)
    end



    def built?
      !@ctx.nil?
    end

    def lang(lang)
    end

    def crashes(crash_handler, mode)
    end

    def target(target)
    end

    def log(logger)
    end

    def population(population)
    end

    def evolution(mode)
    end

    def workers(n)

    end

    def generation(mode)
    end

    private
    def check_errors
      @error.errors << 'The language is missing' if @lang.nil?
      @error.errors << 'The target is missing' if @target.nil?
      @error.errors << 'Evolution mode is missing' unless @evol_mode_set
      @error.errors << 'Generation mode is missing' unless @gen_mode_set
      @error.errors << 'The number of workers must be greater that 0' if @workers <= 0

      raise @error if @error.any?
    end
  end
  
end
