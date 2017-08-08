module Cobaya
  class BaseScript < BasicObject
    attr_reader :_builder
    
    def initialize(builder)
      @_builder = builder
    end
    
    def yes
      true
    end

    def no
      false
    end
  end
end
