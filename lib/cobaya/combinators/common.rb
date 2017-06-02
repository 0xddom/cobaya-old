module Cobaya::Combinators
   class Whatever < Combinator
     def initialize(context)
       super context
     end
     
     def generate
       if @context.max_depth_reached?
         @context.terminals.values.sample
       else
         @context.all.values.sample
       end
     end
   end
   
   class Any < Combinator
     def initialize(context, *symbols)
       super context
       @symbols = symbols
     end
     
     def generate
       @symbols.sample.generate
     end
   end
   
   class Optional < Combinator
     def initialize(context, name)
       super context
       @name = name
       @prob = 0.2
     end

     def include?
       rand > @prob
     end
   end
   
   class Nilable < Combinator
     def initialize(context, name)
       super context
       @name = name
     end
   end
   
   class Multiple < Combinator
     def initialize(context, options)
       super context
       @options = options
     end
   end

   class Action < Combinator
     def initialize(context, returns = false, &block)
       super context
       @block = block
       @returns = returns
     end

     def generate
       @block.call @context
     end

     def include?
       @returns
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
   
   def action(returns = false, &block)
     Cobaya::Combinators::Action.new @context, returns, &block
   end
   
end
