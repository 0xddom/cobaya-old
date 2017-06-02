module Cobaya
  class BaseGenerator
    include SexpHelper

    def self.generate(root)
      @@context = GeneratorContext.new
      @@whatever = Cobaya::Combinators::Whatever.new @@context
    end
    
    def self.get
      @@whatever
    end

    def self.max_child(n)
      @@context.max_child = n
    end

    def self.depth(n)
      @@context.depth = n
    end
    
    def self.any(*symbols)
      Cobaya::Combinators::Any.new @@context, symbols
    end    

    def self.whatever
      Cobaya::Combinators::Whatever.new @@context
    end

    def self.optional(name)
      Cobaya::Combinators::Optional.new @@context, name
    end

    def self.nilable(name)
      Cobaya::Combinators::Nilable.new @@context, name
    end
    
    def self.multiple(*options)
      Cobaya::Combinators::Multiple.new @@context, options
    end

    def self.action(returns = false, &block)
      Cobaya::Combinators::Action.new @@context, returns, block
    end
    
    def self.terminal(name, generator = nil)
      @@context.terminals[name] = (if generator
        Cobaya::Combinators::Terminal.new @@context, name, generator
      else
        Cobaya::Combinators::Literal.new @@context, name
      end)
    end

    def self.non_terminal(name)
      @@context.non_terminals[name] = Cobaya::Combinators::NonTerminal.new @@context, name
    end
  end

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
end
