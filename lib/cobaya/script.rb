require 'cobaya'

module Cobaya

  class Script < BasicObject
    def initialize(builder)
      @builder = builder
    end

    def lang(lang)
      @builder.lang lang
    end

    def crashes(crash_handler, mode)
      @builder.crashes crash_handler, mode
    end

    def target(target)
      @builder.target target
    end
      
    def log(logger)
      @builder.log logger
    end

    def population(population)
      @builder.population population
    end

    def evolution(mode)
      @builder.evolution mode
    end

    def workers(n_workers)
      @builder.workers n_workers
    end

    def generation(mode)
      @builder.generation mode
    end

    def create_fuzzer
      @builder.build
      Fuzzer.new(@builder.ctx)
    end
  end
  
  def fuzzer(builder = FuzzingContextBuilder.new, &block)
    begin
      script = Script.new(builder)
      script.instance_eval(&block)
      script.create_fuzzer
    rescue ContextBuildError => e
      puts "There where some errors with your configuration:"
      e.errors.each do |error|
        puts "  #{error}"
      end
    end
  end

  def fuzzer!(builder = FuzzingContextBuilder.new, &block)
    fuzzer(builder, &block).run
  end
  
end

include Cobaya
