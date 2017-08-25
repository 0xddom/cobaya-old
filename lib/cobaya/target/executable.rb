# coding: utf-8
module Cobaya
  
  ##
  # This class handles the execution of an executable target.
  # The input is received through stdin or by command line
  # argument as a file.
  class ExecutableTarget
    include FileUtils
    
    attr_reader :ctx
    
    def initialize(ctx)
      @ctx = ctx
      cmd = @ctx.cmd
      cmd[0] = File.absolute_path cmd[0]
      @send_to_stdin = !(cmd.any? {|arg| arg.include? '{}'})
      @forced = false
      @cmd = cmd
      @process = nil

      if @ctx.cov?
        @cov_dir = Dir.mktmpdir
      end
      @env = {}
      if @ctx.cov?
        @env['ASAN_OPTIONS'] = "coverage=1:coverage_dir=#{@cov_dir}"
      end
      
      #ChildProcess.posix_spawn = ctx.spawn
    end

    ##
    # Returns the command line.
    def cmd
      (@cmd ? @cmd : @ctx.cmd).join ' '
    end

    ##
    # Executes the command with the input.
    def exec(input)
      @forced = false
      input, out, err = if @send_to_stdin
                          stdin_exec(input)
                        else
                          file_param_exec(input)
                        end
      @ctx.logger.debug { "Executed #{cmd}" }
      rewind out, err
      result = build_result input, out, err
      
      yield result
    end

    private

    attr_accessor :process

    def stdin_exec(input)
      out, err = synced_tmpf 2

      build_proc(@ctx.cmd, stdout: out, stderr: err)
      run_process do
        stdin = process.io.stdin
        stdin.print input
        stdin.close
      end

      return [input, out, err]
    end

    def file_param_exec(input)
      tmpf, out, err = synced_tmpf 3
      tmpf.print input
      tmpf.rewind

      @cmd = build_cmd tmpf.path

      build_proc(@cmd, stdout: out, stderr: err)
      run_process
      
      return [input, out, err]
    end

    def crash?
      process.exit_code != 0
    end
      
    def set_fd(io, fd)
      process.io.send "#{fd}=".to_sym, io if io
    end

    def build_proc(cmd, **fds)
      @process = ChildProcess.build(*cmd)
      process.duplex = true 
      set_fd fds[:stdout], :stdout
      set_fd fds[:stderr], :stderr
      process.environment.merge @env
    end

    def run_process
      process.start
      yield if block_given?
      process.poll_for_exit 3
    rescue ChildProcess::TimeoutError
      process.stop
      @ctx.logger.info { "The child process timeouted" }
      @forced = true
    end

    def build_result(input, output, error)
      meta = {
        input: input,
        output: output.read,
        error: error.read,
        forced: @forced
      }

      if @ctx.cov?
        meta[:cov] = cov_file
      end
      
      Result.new crash?, meta
    end

    def build_cmd(path)
      @ctx.cmd.map { |arg| arg.gsub '{}', path  }
    end

    def cov_file
      CovFile.from_pid(@cov_dir, cmd[0], process.pid)
    rescue Errno::ENOENT
      @ctx.logger.fatal "You set the SanitizerCoverage option, but the target didn't yielded a coverage file. Are you fuzzing a target with SanitizerCoverage?"
      raise ArgumentError.new "SanitizerCoverage was set but the target is not using the plugin"
    end
  end
end
