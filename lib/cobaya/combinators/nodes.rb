module Cobaya::Combinators
    class Terminal
      def initialize(contex, name, generator)
        super context
        @name = name
        @generator = generator
      end
      
      def generate
        s @name, @generator.generate
      end
    end
    
    class Literal
      def initialize(context, name)
        super context
        @name = name
      end
      
      def generate
        s @name
      end
    end
    
    class NonTerminal
      def initialize(context, name)
        super context
        @name = name
      end
    end
end
