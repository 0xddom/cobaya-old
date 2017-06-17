module Cobaya
  class Fragment
    attr_reader :tree, :filename, :code
    
    def initialize(tree, filename = nil)
      @tree = tree
      @filename = filename
      @code = Unparser.unparse tree
    end

    alias_method :to_code, :code
    
    def write_to_io(io)
      io.puts to_code
    end
  end
end
