module Cobaya::Combinators
   class Whatever
     def initialize(context)
       super context
     end
     
     def generate
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
end
