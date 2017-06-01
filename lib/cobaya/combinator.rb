module Cobaya::Combinators
  
  class Combinator

    attr_reader :context

    def initialize(context)
      @context = context
    end

    def generate
      raise "Override this method!"
    end
  end

end
