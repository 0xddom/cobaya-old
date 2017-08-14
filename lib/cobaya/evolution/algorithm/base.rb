module Cobaya
  module Mutation
    def mutations
      [LiteralMutation]
    end
  end
  
  class BaseEvolution
    include Enumerable
    include Mutation

    ##
    # The evolution context
    attr_reader :ctx
    
    def initialize(ctx)
      @ctx = ctx
    end
  end
end
