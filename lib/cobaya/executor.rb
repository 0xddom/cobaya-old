module Cobaya
  class StdinExecutor
    def initialize(file, target, crashes)
      @target = target
      @file = file
      @timeout = 3
      @signal = 9 # KILL
      @crashes = crashes

      set_output_files
    end

    def execute
      raise "Forking forbidden" unless Process.respond_to? :fork
      pid = fork do
        run_target
      end
      Thread.new do
        sleep @timeout
        Process.kill @signal, pid
      end
      Process.waitpid pid
      process_status $?
    end

    private
    def process_status(status)
      unless status.success?
        crash = Crash.new status
        crash.stdout = @stdout.path
        crash.stderr = @stderr.path
        crash.stdin = @file
        crash.collect @crashes

        crash
      end
    end

    def run_target
      $stdin.reopen File.new @file
      $stdout.reopen @stdout
      $stderr.reopen @stderr
      exec [@target, @target]
    end

    def set_output_files
      @stdout = Tempfile.new ['cobaya', '.stdout']
      @stderr = Tempfile.new ['cobaya', '.stderr']
    end
  end
end
