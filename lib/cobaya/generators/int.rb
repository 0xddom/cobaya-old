##
# This part of the module defines the generators related with numbers
module Cobaya::Generators

  ##
  # A generator that creates random numbers
  #
  # :reek:BooleanParameter
  class NumGen
    def initialize(limit, neg = true)
      @limit = limit
      @neg = neg
    end

    def generate
      new_num = rand @limit
      if @neg && rand < 0.5
        -new_num
      else
        new_num
      end
    end
  end

  ##
  # Returns an integer generator
  #
  # :reek:UtilityFunction
  def int(max_int)
    NumGen.new max_int
  end

  ##
  # Returns a float generator
  #
  # :reek:UtilityFunction
  def float(max_float)
    NumGen.new max_float.to_f
  end
end
