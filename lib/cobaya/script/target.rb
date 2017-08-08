module Cobaya
  class ExecutableTargetBlock < BaseScript
    def initialize(cmd, builder)
      super builder
      _builder.cmd = cmd
    end

    def timeout(time)
      _builder.timeout time
    end

    def asan(b)
      _builder.use_asan b
    end

    def spawn(b)
      _builder.use_spawn b
    end

    def cov(b)
      _builder.use_cov b
    end
  end
end
