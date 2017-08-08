module Cobaya
  ##
  # Deprecated
  class SRandom
    include Singleton

    attr_reader :prng
    
    def init(seed)
      @prng = Random.new seed
    end
  end
end
    
