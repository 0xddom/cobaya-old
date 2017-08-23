# coding: utf-8
module Cobaya
  
  ##
  # This class handles the execution of an executable target.
  # The input is received through stdin.
  #--
  # TODO:
  # - ASAN_OPTIONS=coverage=1:coverage_dir=./cov
  # - Convertir esta clase en clase abstracta con las capacidades de ejecutar y
  #   configurar. Y relegar en dos hijos la ejecución por stdin y fichero.
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
      Result.new crash?, {
                   input: input,
                   output: output.read,
                   error: error.read,
                   forced: @forced
                 }
    end

    def build_cmd(path)
      @ctx.cmd.map { |arg| arg.gsub('{}', path) }
    end
    
  end
end
