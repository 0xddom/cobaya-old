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

      [
        :Object,
        :Hash,
        :Numeric,
        :TrueClass,
        :FalseClass,
        :Regexp,
        :Class,
        :Array,
        :Enumerable,
        :BasicObject,
        :String
      ].each do |const|
        constants.add const
      end

      [
        :a, :b, :c
      ].each do |var|
        locals.add var
      end

      available_methods = any(*symbols=known_methods)

      # Temporal variables to avoid duplication
      #multiple_whatever = multiple whatever
      #optional_multiple_whatever = optional multiple_whatever
      str_g = str max_str_len
      sym_g = sym max_str_len
      #nilable_whatever = nilable whatever
      any_asgn = any :send, :lvasgn, :gvasgn, :cvasgn, :ivasgn
      any_var = any :lvar, :cvar, :gvar, :ivar
      multiple_syms = multiple :sym, :dsym

      expr = any :true, :false, :nil, :int, :float, :str,
                 :sym, :self, :lvar, :ivar, :cvar, :gvar,
                 :nth_ref, :zsuper, :dstr, :dsym, :regexp,
                 :array, :hash, :irange, :erange, :const,
                 :defined?, :lvasgn, :ivasgn, :cvasgn,
                 :gvasgn, :casgn, :send, :masgn, :op_asgn,
                 :or_asgn, :and_asgn, :class, :module,
                 :sclass, :def, :defs, :super, :yield,
                 :block, :and, :or, :if, :case, :begin,
                 :while, :until, :while_post, :until_post,
                 :for, :return, :iflipflop, :eflipflop,
                 :match_current_line, :mathc_with_lvasgn

      multiple_exprs = multiple expr
      optional_exprs = optional multiple_exprs
      nilable_expr = nilable expr
                 
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
      terminal :regopt, multiple(:i, :m, :x).force!
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
      non_terminal :dstr, multiple_exprs
      non_terminal :dsym, multiple_exprs
      _non_terminal :xstr, multiple_exprs # Better not execute other things while fuzzing
      non_terminal :regexp, multiple_exprs, :regopt
      non_terminal :array, multiple_exprs
      non_terminal :splat, :lvar
      non_terminal :pair, :sym, expr
      non_terminal :hash, multiple(:pair)
      non_terminal :irange, :int, :int
      non_terminal :erange, :int, :int
      non_terminal :const, nilable(any :cbase, any_var), const_g(constants)
      non_terminal :defined?, :lvar
      non_terminal :lvasgn, lvar(locals), expr
      non_terminal :ivasgn, ivar(instance_vars), expr
      non_terminal :cvasgn, cvar(class_vars), expr
      non_terminal :gvasgn, gvar(globals), expr
      
      non_terminal :e_lvasgn, lvar(locals), override: :lvasgn
      non_terminal :e_ivasgn, ivar(instance_vars), override: :ivasgn
      non_terminal :e_cvasgn, cvar(class_vars), override: :cvasgn
      non_terminal :e_gvasgn, gvar(globals), override: :gvasgn
      incomplete_asgn = any :e_lvasgn, :e_ivasgn, :e_cvasgn, :e_gvasgn
      terminal :e_lvar, lvar_g(locals), override: :lvasgn
      terminal :e_ivar, ivar_g(instance_vars, max_var_len), override: :ivasgn
      terminal :e_cvar, cvar_g(class_vars), override: :cvasgn
      terminal :e_gvar, gvar_g(globals, max_var_len), override: :gvasgn
      mlhs_piece = any :e_lvar, :e_ivar, :e_cvar, :e_gvar
      
      non_terminal :casgn, nilable(any :cbase, :lvar), const(constants), nilable_expr
#      non_terminal :send, nilable(any_var), :sym, multiple_exprs, optional(:block_pass)
      non_terminal :send, nilable(any_var), available_methods, multiple_exprs, optional(:block_pass)
      #non_terminal :csend
      non_terminal :mlhs, multiple(mlhs_piece)    #any(:mlhs, multiple(any_asgn))
      non_terminal :masgn, :mlhs, :array
      non_terminal :op_asgn, incomplete_asgn, any(:+, :-, :*, :/), expr
      non_terminal :or_asgn, incomplete_asgn, expr
      non_terminal :and_asgn, incomplete_asgn, expr
      non_terminal :class, (action do |_|
                              instance_vars.push
                              locals.push
                              class_vars.push
                            end), :const, nilable(:const), expr, (action do |_|
                                                                        instance_vars.pop
                                                                        locals.pop
                                                                        class_vars.pop
                                                                      end)
      non_terminal :module, (action do |_|
                               instance_vars.push
                               locals.push
                               class_vars.push
                             end), :const, expr, (action do |_|
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
                          end), :args, nilable_expr, (action do |_|
                                                            locals.pop
                                                          end)
      non_terminal :defs, :self, lvar(locals), (action do |_|
                                                   locals.push
                                                 end), :args, nilable_expr, (action do |_|
                                                                                   locals.pop
                                                                                 end)
      _non_terminal :undef, multiple_syms
      _non_terminal :alias, :sym, multiple_syms
      non_terminal :args, multiple(:arg), multiple(:optarg), optional(:restarg), optional(:kwarg), optional(:blockarg)
      non_terminal :optarg, lvar(locals), expr
      non_terminal :kwoptarg, lvar(locals), expr
      #non_terminal :arg_expr
      #non_terminal :restarg_expr
      #non_terminal :blockarg_expr
      non_terminal :super, optional_exprs
      non_terminal :yield, optional_exprs
      non_terminal :block, :send, (action do |_|
                                     locals.push
                                   end), :args, :begin, (action do |_|
                                                           locals.pop
                                                         end)
      non_terminal :block_pass, :lvar
      non_terminal :and, expr, expr
      non_terminal :or, expr, expr
      _non_terminal :not, expr
      non_terminal :if, expr, nilable_expr, nilable_expr
      non_terminal :when, multiple_exprs
      non_terminal :case, expr, multiple(:when), expr
      non_terminal :begin, any(:rescue, optional(group multiple any_asgn, multiple_exprs)) #optional_multiple_whatever
      non_terminal :while, expr, any(expr, :break, :next, :redo)
      non_terminal :until, expr, any(expr, :break, :next, :redo)
      non_terminal :while_post, expr, any(expr, :break, :next, :redo)
      non_terminal :until_post, expr, any(expr, :break, :next, :redo)
      non_terminal :for, :lvasgn, expr, any(expr, :break, :next, :redo)
      non_terminal :break, expr
      non_terminal :next, expr
      non_terminal :redo, expr
      non_terminal :return, expr
      non_terminal :resbody, :array, :lvasgn, expr
      non_terminal :rescue, expr, multiple(:resbody), nilable_expr
      non_terminal :ensure, expr, expr
      _non_terminal :preexe, expr
      _non_terminal :postexe, expr
      non_terminal :iflipflop, any_var, any_var
      non_terminal :eflipflop, any_var, any_var
      non_terminal :match_current_line, :regexp
      non_terminal :match_with_lvasgn, :regexp, :lvar

    end


    def known_methods
      [
        :^,
          :~,
          :<,
          :<<,
          :<=,
          :<=>,
          :=~,
          :==,
          :===,
          :>,
          :>=,
          :|,
          :-,
          :-@,
          :!,
          :!~,
          :!=,
        :[],
        :[]=,
           :*,
           :&,
           :%,
           :+,
           :+@,
           :abs,
        :abs2,
        :all?,
        :allocate,
        :angle,
        :any?,
        :append,
        :arg,
        :ascii_only?,
        :assoc,
        :at,
        :b,
        :bsearch,
        :bsearch_index,
        :bytes,
        :bytesize,
        :byteslice,
        :capitalize,
        :capitalize!,
        :casecmp,
        :casecmp?,
        :casefold?,
        :ceil,
        :center,
        :chars,
        :chomp,
        :chomp!,
        :chop,
        :chop!,
        :chr,
        :chunk,
        :chunk_while,
        :class,
        :clear,
        :clone,
        :codepoints,
        :coerce,
        :collect,
        :collect!,
        :collect_concat,
        :combination,
        :compact,
        :compact!,
        :compare_by_identity,
        :compare_by_identity?,
        :concat,
        :conj,
        :conjugate,
        :count,
        :crypt,
        :cycle,
        :default,
        :default=,
                :default_proc,
        :default_proc=,
                     :define_singleton_method,
        :delete,
        :delete!,
        :delete_at,
        :delete_if,
        :denominator,
        :detect,
        :dig,
        :display,
        :div,
        :divmod,
        :downcase,
        :downcase!,
        :drop,
        :drop_while,
        :dump,
        :dup,
        :each,
        :each_byte,
        :each_char,
        :each_codepoint,
        :each_cons,
        :each_entry,
        :each_index,
        :each_key,
        :each_line,
        :each_pair,
        :each_slice,
        :each_value,
        :each_with_index,
        :each_with_object,
        :empty?,
        :encode,
        :encode!,
        :encoding,
        :end_with?,
        :entries,
        :enum_for,
        :eql?,
        :equal?,
        :extend,
        :fdiv,
        :fetch,
        :fetch_values,
        :fill,
        :find,
        :find_all,
        :find_index,
        :finite?,
        :first,
        :fixed_encoding?,
        :flat_map,
        :flatten,
        :flatten!,
        :floor,
        :force_encoding,
        :freeze,
        :frozen?,
        :getbyte,
        :grep,
        :grep_v,
        :group_by,
        :gsub,
        :gsub!,
        :hash,
        :has_key?,
        :has_value?,
        :hex,
        :i,
        :__id__,
        :imag,
        :imaginary,
        :include?,
        :index,
        :infinite?,
        :inherited,
        :initialize_copy,
        :inject,
        :insert,
        :inspect,
        :instance_eval,
        :instance_exec,
        :instance_of?,
        :instance_variable_defined?,
        :instance_variable_get,
        :instance_variables,
        :instance_variable_set,
        :integer?,
        :intern,
        :invert,
        :is_a?,
        :itself,
        :join,
        :keep_if,
        :key,
        :key?,
        :keys,
        :kind_of?,
        :last,
        :lazy,
        :length,
        :lines,
        :ljust,
        :lstrip,
        :lstrip!,
        :magnitude,
        :map,
        :map!,
        :match,
        :match?,
        :max,
        :max_by,
        :member?,
        :merge,
        :merge!,
        :method,
        :method_missing,
        :methods,
        :min,
        :min_by,
        :minmax,
        :minmax_by,
        :modulo,
        :named_captures,
        :names,
        :negative?,
        :new,
        :next,
        :next!,
        :nil?,
        :none?,
        :nonzero?,
        :numerator,
        :object_id,
        :oct,
        :one?,
        :options,
        :ord,
        :pack,
        :partition,
        :permutation,
        :phase,
        :polar,
        :pop,
        :positive?,
        :prepend,
        :private_methods,
        :product,
        :protected_methods,
        :public_method,
        :public_methods,
        :public_send,
        :push,
        :quo,
        :rassoc,
        :real,
        :real?,
        :rect,
        :rectangular,
        :reduce,
        :rehash,
        :reject,
        :reject!,
        :remainder,
        :remove_instance_variable,
        :repeated_combination,
        :repeated_permutation,
        :replace,
        :respond_to?,
        :respond_to_missing?,
        :reverse,
        :reverse!,
        :reverse_each,
        :rindex,
        :rjust,
        :rotate,
        :rotate!,
        :round,
        :rpartition,
        :rstrip,
        :rstrip!,
        :sample,
        :scan,
        :scrub,
        :scrub!,
        :select,
        :select!,
        :send,
        :__send__,
        :setbyte,
        :shift,
        :shuffle,
        :shuffle!,
        :singleton_class,
        :singleton_method,
        :singleton_method_added,
        :singleton_method_removed,
        :singleton_methods,
        :singleton_method_undefined,
        :size,
        :slice,
        :slice!,
        :slice_after,
        :slice_before,
        :slice_when,
        :sort,
        :sort!,
        :sort_by,
        :sort_by!,
        :source,
        :split,
        :squeeze,
        :squeeze!,
        :start_with?,
        :step,
        :store,
        :strip,
        :strip!,
        :sub,
        :sub!,
        :succ,
        :succ!,
        :sum,
        :superclass,
        :swapcase,
        :swapcase!,
        :taint,
        :tainted?,
        :take,
        :take_while,
        :tap,
        :to_a,
        :to_ary,
        :to_c,
        :to_enum,
        :to_f,
        :to_h,
        :to_hash,
        :to_i,
        :to_int,
        :to_proc,
        :to_r,
        :to_s,
        :to_str,
        :to_sym,
        :tr,
        :tr!,
        :transform_values,
        :transform_values!,
        :transpose,
        :tr_s,
        :tr_s!,
        :truncate,
        :trust,
        :uniq,
        :uniq!,
        :unpack,
        :unpack1,
        :unshift,
        :untaint,
        :untrust,
        :untrusted?,
        :upcase,
        :upcase!,
        :update,
        :upto,
        :valid_encoding?,
        :value?,
        :values,
        :values_at,
        :zero?,
        :zip
      ]
      
    end
  end
end
