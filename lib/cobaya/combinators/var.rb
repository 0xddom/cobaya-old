module Cobaya::Combinators
  class Var
    def initialize(context, vars)
      super context
      @vars = vars
    end
    
    abstract_method :name
    
    def generate
      n = name
      @vars.add n
      n
    end
  end
  
  class LVar < Var
    def name
      "var#{IntGen.new(10_000).generate false}".to_sym
    end
  end
  
  class IVar < Var
    def name
      "@var#{IntGen.new(10_000).generate false}".to_sym
    end
  end
  
  class CVar < Var
    def name
      "@@var#{IntGen.new(10_000).generate false}".to_sym
    end
  end
  
  class GVar < Var
    def name
      "$var#{IntGen.new(10_000).generate false}".to_sym
    end
  end
  
  class Const < Var
    def name
      "Const#{IntGen.new(10_000).generate false}".to_sym
    end
  end
end
