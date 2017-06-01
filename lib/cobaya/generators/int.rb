module Cobaya::Generators
  class IntGen
    def initialize(limit)
      @limit
    end

    def generate
      n = rand @limit
      if rand < 0.5 then n else -n end
    end
  end
end
