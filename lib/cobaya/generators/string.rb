module Cobaya::Generators
  class StrGen

    def initialize(len, ascii)
      @max_len = len
      @ascii_only = ascii
    end

    def generate
      "STRING" # TODO
    end
  end

  def str(max_len, ascii = false)
    StrGen.new max_len, ascii
  end
end
    
