##
# This class extends the Sexp class from ruby_parser
class Sexp

  ##
  # Allow the s-expression to be deep cloneable
  def clone
    new = dup
    self.each_index do |n|
      if self[n].class.name == "Sexp"
        new[n] = self[n].clone
      else
        new[n] = self[n]
      end
    end
    new
  end
end
