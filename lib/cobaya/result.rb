module Cobaya

  ##
  # This class stores the result of a test.
  class Result

    ##
    # Metadata specific of the execution.
    attr_reader :meta

    ##
    # Initializes a new result.
    def initialize(was_crash, meta = {})
      @meta = meta
      @was_crash = was_crash
    end

    ##
    # Returns whenever the result is a crash of the target or not.
    def crash?
      @was_crash
    end
  end
end
