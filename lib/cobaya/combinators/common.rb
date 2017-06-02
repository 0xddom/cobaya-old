module Cobaya::Combinators
   class Whatever
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
   
   class Any
     def initialize(context, *symbols)
       super context
       @symbols = symbols
     end
     
     def generate
       @symbols.sample.generate
     end
   end
   
   class Optional
     def initialize(context, name)
       super context
       @name = name
       @prob = 0.2
     end

     def include?
       rand > @prob
     end
   end
   
   class Nilable
     def initialize(context, name)
       super context
       @name = name
     end
   end
   
   class Multiple
     def initialize(context, options)
       super context
       @options = options
     end
   end

   class Action
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
end
