module Cobaya::Generators
  class SymGen
    def initialize(len)
      @str = StrGen.new len
    end

    def generate
      @str.generate.to_sym # Generate a string and convert to a symbol
    end
  end
end
