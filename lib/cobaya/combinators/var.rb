##
# This part of the module defines classes and methods
# related to variables.
module Cobaya::Combinators

  ##
  # This abstract class defines the common parts
  # of the variables combinators.
  class Var < Combinator
    def initialize(context, vars)
      super context
      @vars = vars
    end
    
    def generate
      new_var = name
      @vars.add new_var
      new_var
    end
  end

  ##
  # Defines how the local variables are going to be generated.
  #
  # :reek:UtilityFunction
  class LVar < Var
    def name
      "var#{Cobaya::Generators::NumGen.new(10_000, false).generate}".to_sym
    end
  end

  ##
  # Defines how the instance variables are going to be generated.
  #
  # :reek:UtilityFunction
  class IVar < Var
    def name
      "@var#{Cobaya::Generators::NumGen.new(10_000, false).generate}".to_sym
    end
  end

  ##
  # Defines how the class variables are going to be generated.
  #
  # :reek:UtilityFunction
  class CVar < Var
    def name
      "@@var#{Cobaya::Generators::NumGen.new(10_000, false).generate}".to_sym
    end
  end

  ##
  # Defines how the global variables are going to be generated.
  #
  # :reek:UtilityFunction
  class GVar < Var
    def name
      "$var#{Cobaya::Generators::NumGen.new(10_000, false).generate}".to_sym
    end
  end

  ##
  # Defines how the constants are going to be generated.
  #
  # :reek:UtilityFunction
  class Const < Var
    def name
      "Const#{Cobaya::Generators::NumGen.new(10_000, false).generate}".to_sym
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
