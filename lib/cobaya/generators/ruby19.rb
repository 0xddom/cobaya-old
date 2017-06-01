module Cobaya::Generators
  class Ruby19 < Cobaya::BaseGenerator

    max_int = 4_294_967_295
    max_str_len = 2_000_000
    max_var_len = 30
    locals = Cobaya::VariablesStack.new
    instance_vars = Cobaya::VariablesStack.new
    class_vars = Cobaya::VariablesStack.new
    globals = Cobaya::VariablesStack.new
    
    # Terminals
    terminal :true
    terminal :false
    terminal :nil
    terminal :int, IntGen.new(max_int)
    terminal :float, IntGen.new(max_int.to_f) # Since the value is a float, rand will return floats
    #terminal :complex # Too complicated, maybe later
    #terminal :rational # Too complicated, maybe later
    terminal :str, StrGen.new(max_str_len)
    terminal :string, StrGen.new(max_str_len)
    terminal :sym, SymGen.new(max_str_len)
    terminal :regopt, multiple(:i, :m, :x, :o)
    terminal :self
    terminal :lvar, LVarGen.new(locals)
    terminal :ivar, IVarGen.new(instance_vars, max_var_len)
    terminal :cvar, CVarGen.new(class_vars)
    terminal :gvar, GVarGen.new(globals, max_var_len)
    terminal :nth_ref, NthRefGen.new(max_int)
    #terminal :back_ref # Too complicated, maybe later
    terminal :cbase
    terminal :arg, SymGen.new(max_str_len)
    terminal :restarg, optional(SymGen.new(max_str_len))
    terminal :blockarg, SymGen.new(max_str_len)
    terminal :procarg0, SymGen.new(max_str_len)
    terminal :shadowarg, SymGen.new(max_str_len)
    terminal :kwarg, SymGen.new(max_str_len)
    terminal :kwrestarg, SymGen.new(max_str_len)
    terminal :zsuper
    terminal :lambda
    terminal :retry

    # TODO: Terminar de definir las reglas

    
    # Non terminals
    non_terminal :dstr
    non_terminal :dsym
    non_terminal :xstr
    non_terminal :regexp
    non_terminal :array
    non_terminal :splat
    non_terminal :pair
    non_terminal :hash
    non_terminal :irange
    non_terminal :erange
    non_terminal :const
    non_terminal :defined?
    non_terminal :lvasgn
    non_terminal :ivasgn
    non_terminal :cvasgn
    non_terminal :gvasgn
    non_terminal :casgn
    non_terminal :send
    non_terminal :csend
    non_terminal :mlhs
    non_terminal :masgn
    non_terminal :op_asgn
    non_terminal :or_asgn
    non_terminal :and_asgn
    non_terminal :class
    non_terminal :module
    non_terminal :sclass
    non_terminal :def
    non_terminal :sdef
    non_terminal :undef
    non_terminal :alias
    non_terminal :args
    non_terminal :optarg
    non_terminal :kwoptarg
    non_terminal :arg_expr
    non_terminal :restarg_expr
    non_terminal :blockarg_expr
    non_terminal :super
    non_terminal :yield
    non_terminal :block
    non_terminal :block_pass
    non_terminal :and
    non_terminal :or
    non_terminal :not
    non_terminal :if
    non_terminal :when
    non_terminal :case
    non_terminal :begin
    non_terminal :while
    non_terminal :until
    non_terminal :while_post
    non_terminal :until_post
    non_terminal :for
    non_terminal :break
    non_terminal :next
    non_terminal :redo
    non_terminal :return
    non_terminal :resbody
    non_terminal :rescue
    non_terminal :ensure
    non_terminal :preexe
    non_terminal :postexe
    non_terminal :iflipflop
    non_terminal :eflipflop
    non_terminal :match_current_line
    non_terminal :match_with_lvasgn
  end
end
