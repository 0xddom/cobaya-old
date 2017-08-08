module Cobaya
  class ContextBuildError < RuntimeError
    attr_reader :errors
    
    def initialize
      @errors = []
    end

    def any?
      !@errors.empty?
    end
  end
end
