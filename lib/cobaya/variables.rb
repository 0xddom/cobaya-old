module Cobaya
  class VariablesStack
    def initialize
      @levels = [[]]
    end

    def push
      @levels.push []
    end

    def pop
      @levels.pop
    end

    def add(var)
      @levels.last << var
    end

    def empty?
      not @levels.any { |level| not level.empty? }
    end

    def sample
      @levels.reverse_each do |level|
        return level.sample unless level.empty?
      end
    end
  end
end
