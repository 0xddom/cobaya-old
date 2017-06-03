module Cobaya::Combinators
  
  class Combinator

    attr_reader :context

    def initialize(context)
      @context = context
    end

    def generate
      raise "Override this method!"
    end

    def include?
      true
    end

    def generate?
      include?
    end
  end

end
