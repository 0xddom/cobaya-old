module Cobaya
  class GeneratorContext

  
    
    attr_accessor :terminals, :non_terminals
    attr_accessor :depth, :max_child
    
    def initialize
      @terminals = {}
      @non_terminals = {}
      @curr_depth = 0
      @depth = 0
    end

    def max_depth_reached?
      @curr_depth >= @depth
    end

    def down
      @curr_depth += 1
    end

    def up
      @curr_depth -= 1
      @curr_depth = 0 if @curr_depth < 0
    end
  end
  
  class BaseGenerator
    include SexpHelper
    include Cobaya::Combinators
    include Cobaya::Generators

    def initialize
      @context = Cobaya::GeneratorContext.new
      @whatever = Cobaya::Combinators::Whatever.new @context
    end
    
    def generate(root)
    end
    
    def get
      @whatever.generate
    end

    def max_child(n)
      @context.max_child = n
    end

    def depth(n)
      @context.depth = n
    end
    
 


  end

  
end
