module Cobaya
  class FuzzingContextBuilder
    def initialize
      @error = ContextBuildError.new

      @corpus_backends = []
      @targets = []
      @workers = 1
    end

    def build
      genetic_algorithm = @evol_mode.new @corpus_backends
      
      check_errors
      FuzzingContext.new(@lang,
                         @crash_handler,
                         @targets.map {|target_ctx| ExecutableTarget.new(target_ctx) },
                         @logger,
                         genetic_algorithm,
                         @workers)
    end

    def lang(lang)
      @lang = lang

      self
    end

    def crashes(crash_handler, mode)
      raise 'TODO'
    end

    def add_target(target)
      @targets << target

      self
    end

    def log(logger)
      raise 'TODO'
    end

    def add_corpus(corpus)
      if corpus == :memory
        corpus = []
      end
      if corpus.is_a? String
        corpus = DirCorpus.new(corpus)
      end
      @corpus_backends << corpus

      self
    end

    def evolution(mode)
      case mode
      when :continuous
        @evol_mode = ContinuousEvolution
      else
        @evol_mode = BaseEvolution
        @error.errors << "The evolution mode '#{mode.to_s}' is not supported"
      end

      self
    end

    def workers(n)
      @workers = n
    end

    def generation(mode)
      @gen_mode = mode
    end

    private
    def check_errors
      @error.errors << 'The language is missing' if @lang.nil?
      @error.errors << 'The target is missing' if @targets.empty?
      @error.errors << 'Evolution mode is missing' if @evol_mode.nil?
      @error.errors << 'Generation mode is missing' if @gen_mode.nil?
      @error.errors << 'The number of workers must be greater that 0' if @workers <= 0

      raise @error if @error.any?
    end
  end

  class ExecutableTargetContextBuilder
    attr_writer :cmd

    def initialize
      @timeout = 3
      @use_asan = true
      @use_spawn = true
      @use_cov = true
    end

    def timeout(time)
      @timeout = time
    end

    def use_asan(b)
      @use_asan = b
    end

    def use_spawn(b)
      @use_spawn = b
    end

    def use_cov(b)
      @use_cov = b
    end

    def build
      args = @cmd.split ' '
      ExecutableTargetContext.new(args,
                                  @timeout,
                                  @use_asan,
                                  @use_spawn,
                                  @use_cov,
                                  !(args.include? '{}'))
      
    end
      
  end
end
