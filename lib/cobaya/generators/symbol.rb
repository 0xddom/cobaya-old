module Cobaya::Generators
  class SymGen
    def initialize(len)
      @str = StrGen.new len, true
    end

    def generate
      @str.generate.to_sym # Generate a string and convert to a symbol
    end
  end

  def sym(len)
    SymGen.new len
  end
end
