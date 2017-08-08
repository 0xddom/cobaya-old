module Cobaya
  class FuzzerScript < BaseScript
    def lang(lang)
      _builder.lang lang
    end

    def crashes(crash_handler, mode)
      _builder.crashes crash_handler, mode
    end

    def target(location, &block)
      builder = ExecutableTargetContextBuilder.new
      script = ExecutableTargetBlock.new(location, builder)
      script.instance_eval(&block)
      target = script._builder.build
      _builder.add_target target
    end
      
    def log(logger)
      _builder.log logger
    end

    def corpus(corpus)
      _builder.add_corpus corpus
    end

    def evolution(mode)
      _builder.evolution mode
    end

    def workers(n_workers)
      _builder.workers n_workers
    end

    def generation(mode)
      _builder.generation mode
    end
  end
end
