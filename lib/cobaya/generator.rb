module Cobaya
  class BaseGenerator
    include SexpHelper
    
    protected
    def self.any(*symbols)
      Any.new symbols
    end

    def self.max_child(n)
      @max_child = n
    end

    def self.depth(n)
      @depth = n
    end
    
    def self.whatever
      Whatever.new
    end


    def self.optional(name)
      Optional.new name
    end

    def self.nilable(name)
      Nilable.new name
    end
    
    def self.multiple(*options)
      Multiple.new options
    end

    def self.or(*options)
      Or.new options
    end


    
    def self.terminal(name, generator = nil)
      if generator
        Terminal.new name, generator
      else
        Literal.new name
      end
    end

    def self.non_terminal(name)
      NonTerminal.new name
    end

    private
    class Whatever
    end

    class Any
      def initialize(*symbols)
        @symbols = symbols
      end
    end

    class Terminal
      def initialize(name, generator)
        @name = name
        @generator = generator
      end

      def generate
        s @name, @generator.generate
      end
    end

    class Literal
      def initialize(name)
        @name = name
      end

      def generate
        s @name
      end
    end

    class NonTerminal
      def initialize(name)
        @name = name
      end
    end

    class Optional
      def initialize(name)
        @name = name
      end
    end

    class Nilable
      def initialize(name)
        @name = name
      end
    end

    class Multiple
      def initialize(options)
        @options = options
      end
    end

    class Or
      def initialize(options)
        @options = options
      end
    end
  end
end
