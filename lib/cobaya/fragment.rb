module Cobaya
  class Fragment
    attr_accessor :tree, :filename
    
    def initialize tree, filename
      @tree = tree
      @filename = filename
    end
    
    def to_code
      Unparser.unparse tree
    end
  end
end
