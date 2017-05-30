module Cobaya
  class Fragment
    attr_accessor :tree, :filename
    
    def initialize(tree, filename = nil)
      @tree = tree
      @filename = filename
    end
    
    def to_code
      Unparser.unparse tree
    end

    def write_to_io(io)
      io.puts to_code
    end
  end
end
