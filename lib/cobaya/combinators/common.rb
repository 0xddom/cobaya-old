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

    def debug
      check
      "(WHATEVER choice: #{@choice.debug})"
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
      @symbols = *symbols
    end
    
    def generate
      choice = @symbols.sample
      if choice.respond_to? :generate
        choice.generate
      else
        context.get(choice)&.generate || choice
      end
    end

    def debug
      "(ANY options: (#{@symbols.map(&:to_s).join ' '}))"
    end
  end

  ##
  # A combinator the either returns a node especified
  # by the internal combinator or don't returns anything.
  class Optional < Combinator
    def initialize(context, name, prob = 0.2)
      super context
      @name = name
      @prob = prob
    end
    
    def include?
      rand > @prob
    end

    def generate
      if @name.respond_to? :generate
        @name.generate
      else
        context.get(@name)&.generate || @name
      end
    end

    def debug
      "(OPTIONAL #{}"
    end
  end

  ##
  # A combinator that returns a node especified by the
  # internal combinator or returns nil.
  class Nilable < Combinator
    def initialize(context, name, prob = 0.2)
      super context
      @name = name
      @prob = prob
    end

    def generate
      if rand >= @prob
        if @name.respond_to? :generate
          @name.generate
        else
          context.get(@name)&.generate || @name
        end
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
          if @force
            new_child = choice
          else
            new_child = context.get(choice)&.generate
          end
        end
        children << new_child unless new_child.nil?
      end
      children.flatten
    end
  end

  class Group < Combinator
    def initialize(context, *sequence)
      super context
      @seq = sequence.flatten
    end

    def generate
      @seq.select do |e|
        if e.respond_to? :generate?
          e.generate?
        else
          true
        end
      end.map do |e|
        if e.respond_to? :generate
          [e.generate, e.include?]
        else
          e = context.get e
          #[e&.generate || e if e.nil? then true else e.include? end]
        end
      end.select do |t|
        t[1]
      end.map do |t|
        t[0]
      end
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
    Cobaya::Combinators::Any.new @context, *symbols
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

  def group(*sequence)
    Cobaya::Combinators::Group.new @context, sequence
  end
end
