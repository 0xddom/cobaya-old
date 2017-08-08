module Cobaya
  class BaseEvolution
    include Enumerable

    attr_reader :populations

    def initialize(populations = [])
      @populations = populations
    end

    def each
      raise 'Abstract method!'
    end

    def population
      if @populations.is_a? Array
        @populations.sample
      else
        @populations
      end
    end
  end
end
