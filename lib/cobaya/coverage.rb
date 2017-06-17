module Cobaya
  class Coverage
    include Singleton

    def initialize
      @addresses = Set.new
    end

    def add(cov)
      cov_set = Set.new cov

      if @addresses.size == 0
        @addresses |= cov_set
        return 1
      else
        diff = cov_set - @addresses
        @addresses |= cov_set
        diff.size
      end
    end
  end
end
