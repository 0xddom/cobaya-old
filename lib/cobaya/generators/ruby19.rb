# coding: utf-8
module Cobaya::Generators
  class Ruby19 < Cobaya::BaseGenerator

    def initialize
      super
    
      max_int = 4_294_967_295
      max_str_len = 2_000_000
      max_var_len = 30
      locals = Cobaya::VariablesStack.new
      instance_vars = Cobaya::VariablesStack.new
      class_vars = Cobaya::VariablesStack.new
      globals = Cobaya::VariablesStack.new
      constants = Cobaya::VariablesStack.new
      
      # Terminals
      terminal :true
      terminal :false
      terminal :nil
      terminal :int, int(max_int)
      terminal :float, float(max_int) # Since the value is a float, rand will return floats
      #terminal :complex # Too complicated, maybe later
      #terminal :rational # Too complicated, maybe later
      terminal :str, str(max_str_len)
      terminal :string, str(max_str_len)
      terminal :sym, sym(max_str_len)
      terminal :regopt, multiple(:i, :m, :x, :o)
      terminal :self
      terminal :lvar, lvar_g(locals)
      terminal :ivar, ivar_g(instance_vars, max_var_len)
      terminal :cvar, cvar_g(class_vars)
      terminal :gvar, gvar_g(globals, max_var_len)
      terminal :nth_ref, nthref_g(max_int)
      #terminal :back_ref # Too complicated, maybe later
      terminal :cbase
      terminal :arg, sym(max_str_len)
      terminal :restarg, optional(sym(max_str_len))
      terminal :blockarg, sym(max_str_len)
      terminal :procarg0, sym(max_str_len)
      terminal :shadowarg, sym(max_str_len)
      terminal :kwarg, sym(max_str_len)
      terminal :kwrestarg, sym(max_str_len)
      terminal :zsuper
      terminal :lambda
      terminal :retry
      
      # TODO: Crear las clases que devuelven variables y que añaden a la pila de variables
      #       Crear un método para guardar literales y hacer que se compruebe primero el literal y luego ya se busque por terminales o no terminales
      
      
      # Non terminals
      non_terminal :dstr, multiple(whatever)
      non_terminal :dsym, multiple(whatever)
      non_terminal :xstr, multiple(whatever)
      non_terminal :regexp, multiple(whatever), :regopt
      non_terminal :array, multiple(whatever)
      non_terminal :splat, :lvar
      non_terminal :pair, :sym, whatever
      non_terminal :hash, multiple(:pair)
      non_terminal :irange, :int, :int
      non_terminal :erange, :int, :int
      non_terminal :const, nilable(any :cbase, :lvar)
      non_terminal :defined?, :lvar
      non_terminal :lvasgn, lvar(locals), whatever # Cambiar por un generador que devuelve el símbolo y lo agrega al contexto
      non_terminal :ivasgn, ivar(instance_vars), whatever
      non_terminal :cvasgn, cvar(class_vars), whatever
      non_terminal :gvasgn, gvar(globals), whatever
      non_terminal :casgn, const(constants), whatever
      non_terminal :send, nilable(any :lvar, :gvar, :cvar, :ivar), :sym, multiple(whatever), optional(:block_pass)
      #    non_terminal :csend
      non_terminal :mlhs, any(:mlhs, multiple(any :lvasgn, :gvasgn, :cvasgn, :ivasgn, :send))
      non_terminal :masgn, :mlhs, :array
      non_terminal :op_asgn, any(:send, :lvasgn, :gvasgn, :cvasgn, :ivasgn), :sym, whatever
      non_terminal :or_asgn, any(:send, :lvasgn, :gvasgn, :cvasgn, :ivasgn), whatever
      non_terminal :and_asgn, any(:send, :lvasgn, :gvasgn, :cvasgn, :ivasgn), whatever
      non_terminal :class, action() {|_| instance_vars.push; locals.push; class_vars.push}, :const, nilable(:const), whatever
      non_terminal :module, :const, whatever
      non_terminal :sclass, :lvar, whatever
      non_terminal :def, :args, nilable(whatever)
      non_terminal :defs, :self, :args, nilable(whatever)
      non_terminal :undef, multiple(:sym, :dsym)
      non_terminal :alias, :sym, multiple(:sym, :dsym)
      non_terminal :args, multiple(:arg), multiple(:optarg), optional(:restarg), optional(:kwarg), optional(:blockarg)
      non_terminal :optarg, :sym, whatever
      non_terminal :kwoptarg, :sym, whatever
      #non_terminal :arg_expr
      #non_terminal :restarg_expr
      #non_terminal :blockarg_expr
      non_terminal :super, optional(multiple(whatever))
      non_terminal :yield, optional(multiple(whatever))
      non_terminal :block, :send, :args, :begin
      non_terminal :block_pass, :lvar
      non_terminal :and, whatever, whatever
      non_terminal :or, whatever, whatever
      non_terminal :not, whatever
      non_terminal :if, whatever, nilable(whatever), nilable(whatever)
      non_terminal :when, multiple(whatever)
      non_terminal :case, whatever, multiple(:when), whatever
      non_terminal :begin, optional(multiple whatever)
      non_terminal :while, whatever, whatever
      non_terminal :until, whatever, whatever
      non_terminal :while_post, whatever, whatever
      non_terminal :until_post, whatever, whatever
      non_terminal :for, :lvasgn, whatever, whatever
      non_terminal :break, whatever
      non_terminal :next, whatever
      non_terminal :redo, whatever
      non_terminal :return, whatever
      non_terminal :resbody, :array, :lvasgn, whatever
      non_terminal :rescue, whatever, multiple(:resbody), nilable(whatever)
      non_terminal :ensure, whatever, whatever
      non_terminal :preexe, whatever
      non_terminal :postexe, whatever
      non_terminal :iflipflop, any(:lvar, :cvar, :gvar, :ivar), any(:lvar, :cvar, :gvar, :ivar)
      non_terminal :eflipflop, any(:lvar, :cvar, :gvar, :ivar), any(:lvar, :cvar, :gvar, :ivar)
      non_terminal :match_current_line, :regexp
      non_terminal :match_with_lvasgn, :regexp, :lvar
      
    end
  end
end
