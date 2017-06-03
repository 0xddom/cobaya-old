module Cobaya::Generators
  class StrGen

    def initialize(len, ascii)
      @max_len = len
      @ascii_only = ascii
    end

    def generate
      source.shuffle[0,@max_len].join
    end

    def source
      if @ascii_only
        [*('a'..'z'),*('0'..'9')]
      else
        (0..255).to_a.map(&:chr)
      end
    end
  end

  def str(max_len, ascii = false)
    StrGen.new max_len, ascii
  end
end
    
