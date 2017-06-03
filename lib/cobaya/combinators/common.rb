##
# This part of the module defines the combinators that help
# combining other combinators, execute actions during generation, etc.
module Cobaya::Combinators
  
  ##
  # A combinator that returns a random node between
  # the terminals and non-terminals.
  class Whatever < Combinator
    def initialize(context)
      super context
      clear
    end

    def generate?
      check
      @choice.generate?
    end
    
    def generate
      check
      choice = @choice
      clear
      choice.generate
    end

    def include?
      check
      @choice.include?
    end

    private
    def check
      @choice = context.get_table.values.sample if @choice.nil?
    end

    def clear
      @choice = nil
    end
  end

  ##
  # A combinator that returns a random node between
  # a set of options.
  class Any < Combinator
    def initialize(context, *symbols)
      super context
      @symbols = symbols
    end
    
    def generate
      @symbols.sample.generate
    end
  end

  ##
  # A combinator the either returns a node especified
  # by the internal combinator or don't returns anything.
  class Optional < Combinator
    def initialize(context, name)
      super context
      @name = name
      @prob = 0.2
    end
    
    def include?
      rand > @prob
    end

    def generate
      @name.generate
    end
  end

  ##
  # A combinator that returns a node especified by the
  # internal combinator or returns nil.
  class Nilable < Combinator
    def initialize(context, name)
      super context
      @name = name
      @prob = 0.2
    end

    def generate
      if rand < @prob
        @name.generate
      end
    end
  end

  ##
  # A combinator that returns a set of nodes from a set
  # of posible options
  class Multiple < Combinator
    def initialize(context, *options)
      super context
      @options = options.flatten
    end

    def force!
      @force = true
      self
    end

    def generate
      children = []
      rand(1..context.max_child).times do |_|
        choice = @options.sample
        if choice.respond_to? :generate
          new_child = choice.generate
        else
          new_child = choice if @force
        end
        children << new_child unless new_child.nil?
      end
      children.flatten
    end
  end

  ##
  # A combinator that executes an action during the generation process.
  #
  # :reek:BooleanParameter
  class Action < Combinator
    def initialize(context, returns = false, &block)
      super context
      @block = block
      @returns = returns
    end
    
    def generate
      @block.call context
    end
    
    def include?
      @returns
    end

    def generate?
      true # Always generate actions, no matter if returns or not.
    end
  end
  
  def any(*symbols)
    Cobaya::Combinators::Any.new @context, symbols
  end    
  
  def whatever
    Cobaya::Combinators::Whatever.new @context
  end
  
  def optional(name)
    Cobaya::Combinators::Optional.new @context, name
  end
  
  def nilable(name)
    Cobaya::Combinators::Nilable.new @context, name
  end
  
  def multiple(*options)
    Cobaya::Combinators::Multiple.new @context, options
  end

  ##
  # :reek:BooleanParameter
  def action(returns = false, &block)
    Cobaya::Combinators::Action.new @context, returns, &block
  end
end
