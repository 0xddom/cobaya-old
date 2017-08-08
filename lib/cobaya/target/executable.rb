# coding: utf-8
module Cobaya
  # TODO: Añadir la opcion de enviar por parametro
  # TODO: ASAN_OPTIONS=coverage=1:coverage_dir=./cov
  
  class ExecutionResult
    attr_reader :exit_code
    attr_reader :in, :out, :err

    def initialize(exit_code, _in, out, err, forced)
      @exit_code = exit_code
      @in = _in
      @out = out.read
      @err = err.read
      @forcefully_closed = forced
    end

    def forcefully_closed?
      @forcefully_closed
    end

    def crash?
      @exit_code != 0
    end
  end
  
  class ExecutableTarget
    def initialize(ctx)
      @ctx = ctx
      cmd = File.absolute_path ctx.cmd[0]
      @ctx.cmd[0] = cmd
      
      ChildProcess.posix_spawn = ctx.spawn
    end

    def exec(input)
      process = ChildProcess.build(*@ctx.cmd)
      process.duplex = true
      forcefully_closed = false

      out = Tempfile.new
      err = Tempfile.new

      out.sync = true
      err.sync = true
      process.io.stdout = out
      process.io.stderr = err

      process.start
      process.io.stdin.puts input
      process.io.stdin.close

      begin
        process.poll_for_exit @ctx.timeout
      rescue ChildProcess::TimeoutError
        process.stop
        forcefully_closed = true
      end

      out.rewind
      err.rewind

      result = ExecutionResult.new process.exit_code,
                                   input,
                                   out,
                                   err,
                                   forcefully_closed
      yield result
    end
  end
end
