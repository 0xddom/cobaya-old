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
end
