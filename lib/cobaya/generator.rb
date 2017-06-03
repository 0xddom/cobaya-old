module Cobaya
  class GeneratorContext
    attr_accessor :terminals, :non_terminals
    attr_accessor :max_depth, :max_child
    attr_reader :depth
    
    def initialize
      @terminals = {}
      @non_terminals = {}
      @depth = 0
      @max_depth = 0
    end

    def max_depth_reached?
      @depth >= @max_depth
    end

    def down
      @depth += 1
    end

    def up
      @depth -= 1
      @depth = 0 if @depth < 0
    end

    def get(sym)
      if max_depth_reached?
        @terminals[sym]
      else
        @terminals[sym] || @non_terminals[sym]
      end
    end

    def get_table
      if max_depth_reached?
        @terminals
      else
        {}.merge @terminals.merge @non_terminals
      end
    end
  end
  
  class BaseGenerator
    include Cobaya::Generators
    include Cobaya::Combinators

    def initialize
      @context = Cobaya::GeneratorContext.new
      @whatever = Cobaya::Combinators::Whatever.new @context
    end
    
    def generate(root = :begin)
      @context.get(root).generate
    end
    
    def get
      @whatever.generate
    end

    def max_child(n)
      @context.max_child = n
    end

    def max_depth(n)
      @context.max_depth = n
    end
  end
end
