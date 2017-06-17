##
# This part of the module defines the classes and method for
# creating grammatical nodes.
module Cobaya::Combinators

  ##
  # A combiator that defines a terminal with a primitive type
  class Terminal < Combinator
    include Cobaya::SexpHelper
    
    def initialize(context, name, generator, override: nil)
      super context
      @name = name
      @generator = generator
      @override = override
    end
    
    def generate
      if @override.nil?
        name = @name
      else
        name = @override
      end
      s name, @generator.generate
    end
  end

  ##
  # A combinator that defines a terminal with no values appart
  # from itself.
  class Literal < Combinator
    include Cobaya::SexpHelper
    
    def initialize(context, name, override: nil)
      super context
      @name = name
      @override = override
    end
    
    def generate
      if @override.nil?
        s @name
      else
        s @override
      end
    end
  end

  ##
  # A combinator that defines a non-terminal type of node.
  class NonTerminal < Combinator
    include Cobaya::SexpHelper
    
    def initialize(context, name, children, override: nil)
      super context
      @name = name
      @children = children
      @override = override
    end

    def generate
      context.down
      children = @children.map do |child|
        context.get(child) || child
      end.select do |child|
        if child.respond_to? :generate?
          child.generate?
        else
          true
        end
      end.map do |child|
        if child.respond_to? :generate
          [child.generate, child.include?]
        else
          [child,true]
        end
      end.select do |tuple|
        tuple[1]
      end.map do |tuple|
        tuple[0]
      end.flatten
      context.up
      
      s(if @override.nil? then @name else @override end, children)
    end
  end
  
  
  def terminal(name, generator = nil, override: nil)
    @context.terminals[name] = (if generator
                                Cobaya::Combinators::Terminal.new @context, name, generator, override: override
                               else
                                 Cobaya::Combinators::Literal.new @context, name, override: override
                                end)
  end
  
  def non_terminal(name, *children, override: nil)
    @context.non_terminals[name] =
      Cobaya::Combinators::NonTerminal.new @context, name, children, override: override
  end
end
