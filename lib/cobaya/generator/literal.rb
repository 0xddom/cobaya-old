module Cobaya

  module Literals
  end
  
  ##
  # Implements a method that generates the true keyword
  class Literals::True
    def generate
      [:true]
    end
  end

  ##
  # Implements a method that generates the false keyword
  class Literals::False
    def generate
      [:false]
    end
  end

  ##
  # Implements a method that generates the nil keyword
  class Literals::Nil
    def generate
      [:nil]
    end
  end
  
  ##
  # Implements a method that generates integers
  class Literals::Int

    def initialize(limit, neg_prob)
      @limit = limit
      @neg_prob = neg_prob
    end
    
    def generate
      neg = rand < @neg_prob
      num = rand @limit
      if neg
        num = -num
      end
      [:int, num]
    end
  end

  ##
  # Implements a method that generates floats
  class Literals::Float

    def initialize(limit, neg_prob)
      @limit = limit
      @neg_prob = neg_prob
    end
    
    def generate
      neg = rand < @neg_prob
      num = rand(@limit) * rand
      if neg
        num = -num
      end
      [:float, num]
    end
  end

  ##
  # Implements a method that generates strings
  class Literals::Str
    def initialize(max_length, ascii_only)
      @max_length = max_length
      @ascii_only = ascii_only
    end
    
    def generate
      [:str, source.shuffle[0,@max_length].join]
    end

    private
    def source
      if @ascii_only
        [*('a'..'z'),*('A'..'Z'),*('0'..'9')]
      else
        (0..255).to_a.map(&:chr)
      end
    end
  end

  ##
  # Implements a method that generates symbols
  class Literals::Sym
    include Cobaya::Literals
    
    def initialize(length)
      @str_gen = Str.new(length, true)
    end
    
    def generate
      [:sym, @str_gen.generate[1].to_sym]
    end
  end
  
  ##
  # This class stores a literal generation logic
  class Literal
    include SexpHelper

    ##
    # The symbol for the s-exp
    attr_reader :sym

    ##
    # The probability
    attr_reader :prob

    ##
    # The generator object
    attr_reader :gen

    ##
    # Initializes a literal
    def initialize(sym, prob, gen, gen_args)
      @sym = sym
      @prob = prob
      @gen = gen.new(*gen_args)
    end

    ##
    # Builds a s-exp with a literal expression
    def generate
      s(*gen.generate)
    end
  end
  
  ##
  # This class creates literal nodes of the AST
  module LiteralGenerator

    include Literals

    ##
    # Checks if the given symbol is a literal
    def self.literal?(sym)
      literals.map{|l| l[0]}.include? sym
    end

    ##
    # Returns a random literal
    def self.random
      prob = rand
      last = nil
      for lit in literals
        last = lit
        break if lit[1] > prob
      end

      Literal.new(*last)
    end

    private

    def self.literals
      [
        [:true,  0.1,  True,  []],
        [:false, 0.2,  False, []],
        [:nil,   0.5,  Nil,   []],
        [:int,   0.7,  Int,   [5_000_000_000, 0.5]],
        [:float, 0.8,  Float, [5_000_000_000, 0.5]],
        [:str,   0.95, Str,   [23, true]],
        [:sym,   1,    Sym,   [10]]
      ]
    end
  end
end
