# coding: utf-8

##
# In this part of the module is implemented a generator for ruby 1.9 code.
module Cobaya::Generators

  ##
  # This generator returns ruby 1.9 ASTs
  #
  # :reek:UncommunicativeModuleName
  class Ruby19 < Cobaya::BaseGenerator

    def initialize
      super

      max_child 6
      max_depth 10
      
      max_int = 4_294_967_295
      max_str_len = 23 # Why? Because https://goo.gl/WaTlzw
      max_var_len = 15
      locals = Cobaya::VariablesStack.new
      instance_vars = Cobaya::VariablesStack.new
      class_vars = Cobaya::VariablesStack.new
      globals = Cobaya::VariablesStack.new
      constants = Cobaya::VariablesStack.new

      # Temporal variables to avoid duplication
      multiple_whatever = multiple whatever
      optional_multiple_whatever = optional multiple_whatever
      str_g = str max_str_len
      sym_g = sym max_str_len
      nilable_whatever = nilable whatever
      any_asgn = any :send, :lvasgn, :gvasgn, :cvasgn, :ivasgn
      any_var = any :lvar, :cvar, :gvar, :ivar
      multiple_syms = multiple :sym, :dsym

      def _terminal(*); end
      def _non_terminal(*); end
      
      # Terminals
      terminal :true
      terminal :false
      terminal :nil
      terminal :int, int(max_int)
      terminal :float, float(max_int)
      #terminal :complex # Too complicated, maybe later
      #terminal :rational # Too complicated, maybe later
      terminal :str, str_g
      #terminal :string, str_g # Unparser fails with this one
      terminal :sym, sym_g
      _terminal :regopt, multiple(:i, :m, :x, :o).force!
      _terminal :self
      _terminal :lvar, lvar_g(locals)
      _terminal :ivar, ivar_g(instance_vars, max_var_len)
      _terminal :cvar, cvar_g(class_vars)
      _terminal :gvar, gvar_g(globals, max_var_len)
      _terminal :nth_ref, nthref_g(max_var_len)
      #terminal :back_ref # Too complicated, maybe later
      _terminal :cbase
      _terminal :arg, sym_g
      _terminal :restarg, optional(sym_g)
      _terminal :blockarg, sym_g
      _terminal :procarg0, sym_g
      _terminal :shadowarg, sym_g
      _terminal :kwarg, sym_g
      _terminal :kwrestarg, sym_g
      _terminal :zsuper
      _terminal :lambda
      _terminal :retry
      
      # TODO: Crear las clases que devuelven variables y que añaden a la pila de variables
      #       Crear un método para guardar literales y hacer que se compruebe primero el literal y luego ya se busque por terminales o no terminales
      
      
      # Non terminals
      non_terminal :dstr, multiple_whatever
      non_terminal :dsym, multiple_whatever
      _non_terminal :xstr, multiple_whatever
      _non_terminal :regexp, multiple_whatever, :regopt
      _non_terminal :array, multiple_whatever
      _non_terminal :splat, :lvar
      _non_terminal :pair, :sym, whatever
      _non_terminal :hash, multiple(:pair)
      _non_terminal :irange, :int, :int
      _non_terminal :erange, :int, :int
      _non_terminal :const, nilable(any :cbase, :lvar)
      _non_terminal :defined?, :lvar
      non_terminal :lvasgn, lvar(locals), whatever
      _non_terminal :ivasgn, ivar(instance_vars), whatever
      _non_terminal :cvasgn, cvar(class_vars), whatever
      _non_terminal :gvasgn, gvar(globals), whatever
      _non_terminal :casgn, const(constants), whatever
      _non_terminal :send, nilable(any_var), :sym, multiple_whatever, optional(:block_pass)
      #non_terminal :csend
      _non_terminal :mlhs, any(:mlhs, multiple(any_asgn))
      _non_terminal :masgn, :mlhs, :array
      _non_terminal :op_asgn, any_asgn, :sym, whatever
      _non_terminal :or_asgn, any_asgn, whatever
      _non_terminal :and_asgn, any_asgn, whatever
      _non_terminal :class, action() {|_| instance_vars.push; locals.push; class_vars.push}, :const, nilable(:const), whatever
      _non_terminal :module, :const, whatever
      _non_terminal :sclass, :lvar, whatever
      _non_terminal :def, :args, nilable_whatever
      _non_terminal :defs, :self, :args, nilable_whatever
      _non_terminal :undef, multiple_syms
      _non_terminal :alias, :sym, multiple_syms
      _non_terminal :args, multiple(:arg), multiple(:optarg), optional(:restarg), optional(:kwarg), optional(:blockarg)
      _non_terminal :optarg, :sym, whatever
      _non_terminal :kwoptarg, :sym, whatever
      #non_terminal :arg_expr
      #non_terminal :restarg_expr
      #non_terminal :blockarg_expr
      _non_terminal :super, optional_multiple_whatever
      _non_terminal :yield, optional_multiple_whatever
      _non_terminal :block, :send, :args, :begin
      _non_terminal :block_pass, :lvar
      _non_terminal :and, whatever, whatever
      _non_terminal :or, whatever, whatever
      _non_terminal :not, whatever
      _non_terminal :if, whatever, nilable_whatever , nilable_whatever
      _non_terminal :when, multiple_whatever
      _non_terminal :case, whatever, multiple(:when), whatever
      non_terminal :begin, optional_multiple_whatever
      _non_terminal :while, whatever, whatever
      _non_terminal :until, whatever, whatever
      _non_terminal :while_post, whatever, whatever
      _non_terminal :until_post, whatever, whatever
      _non_terminal :for, :lvasgn, whatever, whatever
      _non_terminal :break, whatever
      _non_terminal :next, whatever
      _non_terminal :redo, whatever
      _non_terminal :return, whatever
      _non_terminal :resbody, :array, :lvasgn, whatever
      _non_terminal :rescue, whatever, multiple(:resbody), nilable_whatever
      _non_terminal :ensure, whatever, whatever
      _non_terminal :preexe, whatever
      _non_terminal :postexe, whatever
      _non_terminal :iflipflop, any_var, any_var
      _non_terminal :eflipflop, any_var, any_var
      _non_terminal :match_current_line, :regexp
      _non_terminal :match_with_lvasgn, :regexp, :lvar

    end
  end
end
