module Cobaya::Generators
  class LVarGen
    def initialize(context)
      @content = context
    end

    def generate
      raise "No local variables to choose from!" if context.empty?
      context.sample
    end
  end

  class IVarGen
    def initialize(context, max_len)
      @content = context
      @max_len = max_len
    end

    def generate
      if context.empty?
        "@#{StrGen.new(@max_len).generate}".to_sym
      else
        context.sample
      end
    end
  end

  class CVarGen
    def initialize(context)
      @content = context
    end

    def generate
      raise "No class variables to choose from!" if context.empty?
      "@@#{context.sample}".to_sym
    end
  end

  class GVarGen
    def initialize(context, max_len)
      @content = context
      @max_len = max_len
    end

    def generate
      if context.empty?
        "$#{StrGen.new(@max_len).generate}".to_sym
      else
        context.sample
      end
    end
  end

  class NthRefGen
    def initialize(max)
      @max = max
    end

    def generate
      "$#{IntGen.new(max).generate}".to_sym
    end
  end

end
