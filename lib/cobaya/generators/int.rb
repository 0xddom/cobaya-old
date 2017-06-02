module Cobaya::Generators
  class IntGen
    def initialize(limit)
      @limit
    end

    def generate(neg = true)
      n = rand @limit
      if neg
        if rand < 0.5 then n else -n end
      else
        n
      end
    end
  end

  def int(max_int)
    IntGen.new max_int
  end

  def float(max_float)
    IntGen.new max_float.to_f
  end
end
