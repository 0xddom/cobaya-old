module Cobaya::Generators
  class VarGen
    attr_reader :context
    
    def initialize(context)
      @context = context
    end
  end
  
  class LVarGen < VarGen
    def initialize(context)
      super context
    end

    def generate
      raise "No local variables to choose from!" if context.empty?
      context.sample
    end
  end

  class IVarGen < VarGen
    def initialize(context, max_len)
      super context
      @max_len = max_len
    end

    def generate
      if context.empty?
        "@ivar_#{StrGen.new(@max_len, true).generate}".to_sym
      else
        context.sample
      end
    end
  end

  class CVarGen < VarGen
    def initialize(context)
      super context
    end

    def generate
      raise "No class variables to choose from!" if context.empty?
      "@@#{context.sample}".to_sym
    end
  end

  class GVarGen < VarGen
    def initialize(context, max_len)
      super context
      @max_len = max_len
    end

    def generate
      if context.empty?
        "$gvar_#{StrGen.new(@max_len, true).generate}".to_sym
      else
        context.sample
      end
    end
  end

  class NthRefGen
    def initialize(max)
      @max = max
    end

    def generate
      "$#{NumGen.new(@max, false).generate}".to_sym
    end
  end

  def lvar_g(locals)
    LVarGen.new locals
  end
  
  def ivar_g(instance_vars, max_len)
    IVarGen.new instance_vars, max_len
  end
  
  def cvar_g(class_vars)
    CVarGen.new class_vars
  end
  
  def gvar_g(globals, max_len)
    GVarGen.new globals, max_len
  end
  
  def nthref_g(max_int)
    NthRefGen.new max_int
  end
  
end
