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
      locals = Cobaya::VariablesStack.new :locals
      instance_vars = Cobaya::VariablesStack.new :instance_vars
      class_vars = Cobaya::VariablesStack.new :class_vars
      globals = Cobaya::VariablesStack.new :globals
      constants = Cobaya::VariablesStack.new :constants

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
      terminal :regopt, multiple(:i, :m, :x, :o).force!
      terminal :self
      terminal :lvar, lvar_g(locals)
      terminal :ivar, ivar_g(instance_vars, max_var_len)
      terminal :cvar, cvar_g(class_vars)
      terminal :gvar, gvar_g(globals, max_var_len)
      terminal :nth_ref, nthref_g(max_var_len)
      #terminal :back_ref # Too complicated, maybe later
      terminal :cbase
      terminal :arg, lvar(locals)
      terminal :restarg, optional(lvar(locals))
      terminal :blockarg, lvar(locals)
      #terminal :procarg0, sym_g
      #terminal :shadowarg, sym_g
      terminal :kwarg, lvar(locals)
      terminal :kwrestarg, lvar(locals)
      terminal :zsuper
      _terminal :lambda
      terminal :retry
      
      # TODO: Crear las clases que devuelven variables y que añaden a la pila de variables
      #       Crear un método para guardar literales y hacer que se compruebe primero el literal y luego ya se busque por terminales o no terminales
      
      # Non terminals
      non_terminal :dstr, multiple_whatever
      non_terminal :dsym, multiple_whatever
      _non_terminal :xstr, multiple_whatever # Better not execute other things while fuzzing
      non_terminal :regexp, multiple_whatever, :regopt
      non_terminal :array, multiple_whatever
      non_terminal :splat, :lvar
      non_terminal :pair, :sym, whatever
      non_terminal :hash, multiple(:pair)
      non_terminal :irange, :int, :int
      non_terminal :erange, :int, :int
      non_terminal :const, nilable(any :cbase, any_var), const(constants)
      non_terminal :defined?, :lvar
      non_terminal :lvasgn, lvar(locals), nilable_whatever
      non_terminal :ivasgn, ivar(instance_vars), nilable_whatever
      non_terminal :cvasgn, cvar(class_vars), nilable_whatever
      non_terminal :gvasgn, gvar(globals), nilable_whatever
      non_terminal :casgn, nilable(any :cbase, :lvar), const(constants), nilable_whatever
      non_terminal :send, nilable(any_var), :sym, multiple_whatever, optional(:block_pass)
      #non_terminal :csend
      non_terminal :mlhs, multiple(any_asgn)    #any(:mlhs, multiple(any_asgn))
      non_terminal :masgn, :mlhs, :array
      non_terminal :op_asgn, any_asgn, any(:+, :-, :*, :/), whatever
      non_terminal :or_asgn, any_asgn, whatever
      non_terminal :and_asgn, any_asgn, whatever
      non_terminal :class, (action do |_|
                              instance_vars.push
                              locals.push
                              class_vars.push
                            end), :const, nilable(:const), whatever, (action do |_|
                                                                        instance_vars.pop
                                                                        locals.pop
                                                                        class_vars.pop
                                                                      end)
      non_terminal :module, (action do |_|
                               instance_vars.push
                               locals.push
                               class_vars.push
                             end), :const, whatever, (action do |_|
                                                        instance_vars.pop
                                                        locals.pop
                                                        class_vars.pop
                                                      end)
      non_terminal :sclass, (action do |_|
                               instance_vars.push
                               locals.push
                               class_vars.push
                             end), :lvar, whatever, (action do |_|
                                                       instance_vars.pop
                                                       locals.pop
                                                       class_vars.pop
                                                     end)
      non_terminal :def, lvar(locals), (action do |_|
                            locals.push
                          end), :args, nilable_whatever, (action do |_|
                                                            locals.pop
                                                          end)
      non_terminal :defs, :self, lvar(locals), (action do |_|
                                                   locals.push
                                                 end), :args, nilable_whatever, (action do |_|
                                                                                   locals.pop
                                                                                 end)
      non_terminal :undef, multiple_syms
      non_terminal :alias, :sym, multiple_syms
      non_terminal :args, multiple(:arg), multiple(:optarg), optional(:restarg), optional(:kwarg), optional(:blockarg)
      non_terminal :optarg, lvar(locals), whatever
      non_terminal :kwoptarg, lvar(locals), whatever
      #non_terminal :arg_expr
      #non_terminal :restarg_expr
      #non_terminal :blockarg_expr
      non_terminal :super, optional_multiple_whatever
      non_terminal :yield, optional_multiple_whatever
      non_terminal :block, :send, (action do |_|
                                     locals.push
                                   end), :args, :begin, (action do |_|
                                                           locals.pop
                                                         end)
      non_terminal :block_pass, :lvar
      non_terminal :and, whatever, whatever
      non_terminal :or, whatever, whatever
      _non_terminal :not, whatever
      non_terminal :if, whatever, nilable_whatever, nilable_whatever
      non_terminal :when, multiple_whatever
      non_terminal :case, whatever, multiple(:when), whatever
      non_terminal :begin, optional(group multiple any_asgn, multiple_whatever) #optional_multiple_whatever
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
      non_terminal :rescue, whatever, multiple(:resbody), nilable_whatever
      non_terminal :ensure, whatever, whatever
      non_terminal :preexe, whatever
      non_terminal :postexe, whatever
      non_terminal :iflipflop, any_var, any_var
      non_terminal :eflipflop, any_var, any_var
      non_terminal :match_current_line, :regexp
      non_terminal :match_with_lvasgn, :regexp, :lvar

    end
  end
end
