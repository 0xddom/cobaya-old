BinaryOperators = [
  "+", "-", "*", "/"
]

class ReWriterVisitor < SexpProcessor
  def initialize
    super
    self.strict = false
    self.require_empty = false
    self.expected = String
    self.default_method = :_default_method
  end

  def process_lit(exp)
    exp[1].to_s
  end

  def process_call(exp)
    p exp
    exp.shift # Remove :call
    invoker = process exp.shift
    method = exp.shift.to_s

    args = exp.map do |node|
      if node.class.name == "Sexp"
        process node
      else
        node.to_s
      end
    end

    if BinaryOperators.include? method
      "#{invoker}#{method}#{args[0]}"
    else
      ""
    end
    
  end

  def process_true(exp)
    "true"
  end

  def _default_method(exp)
    p exp
    ""
  end
end
