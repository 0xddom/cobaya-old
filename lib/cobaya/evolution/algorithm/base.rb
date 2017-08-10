module Cobaya
  class BaseEvolution
    include Enumerable

    ##
    # The evolution context
    attr_reader :ctx
    
    def initialize(ctx)
      @ctx = ctx
    end
  end
end
