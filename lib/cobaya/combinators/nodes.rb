module Cobaya::Combinators
    class Terminal < Combinator
      def initialize(contex, name, generator)
        super context
        @name = name
        @generator = generator
      end
      
      def generate
        s @name, @generator.generate
      end
    end
    
    class Literal < Combinator
      def initialize(context, name)
        super context
        @name = name
      end
      
      def generate
        s @name
      end
    end
    
    class NonTerminal < Combinator
      def initialize(context, name)
        super context
        @name = name
      end
    end

       
    def terminal(name, generator = nil)
      @context.terminals[name] = (if generator
        Cobaya::Combinators::Terminal.new @context, name, generator
      else
        Cobaya::Combinators::Literal.new @context, name
      end)
    end

    def non_terminal(name, *)
      @context.non_terminals[name] = Cobaya::Combinators::NonTerminal.new @context, name
    end
end
