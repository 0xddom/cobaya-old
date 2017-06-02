module Cobaya::Combinators
  class Var < Combinator
    def initialize(context, vars)
      super context
      @vars = vars
    end
    
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

  def lvar(locals)
    LVar.new @context, locals
  end

  def ivar(instance_vars)
    IVar.new @context, instance_vars
  end

  def cvar(class_vars)
    CVar.new @context, class_vars
  end

  def gvar(globals)
    GVar.new @context, globals
  end

  def const(consts)
    Const.new @context, consts
  end
    
end
