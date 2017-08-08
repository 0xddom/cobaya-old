module Cobaya
  ##
  # Deprecated
  class StdinExecutor
    def initialize(file, target, crashes)
      @target = target
      @file = file
      @timeout = 3
      @signal = 9 # KILL
      @crashes_dir = crashes
      @env = {
        'ASAN_OPTIONS' => 'coverage=1:coverage_dir=./cov'
      }

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
      
      [get_cov(pid), process_status($?)]
    end

    private
    def process_status(status)
      unless status.success?
        crash = Crash.new status
        crash.stdout = @stdout.path
        crash.stderr = @stderr.path
        crash.stdin = @file
        crash.collect @crashes_dir

        crash
      end
    end

    def get_cov(pid)
      cov_filename = File.join File.absolute_path('cov'), cov_filename(pid)
      return nil unless File.exist? cov_filename
      cov = File.open cov_filename, 'rb'
      magic = cov.read 8
      # Return nil if magic number validation fails
      unless valid? magic
        puts "Failed #{p magic}"
        return nil
      end
      offsiz = if magic[0] == 'd' then 8 else 4 end
      get_addresses cov, offsiz
    end

    def valid?(magic)
      #(magic.to_s == "d\xFF\xFF\xFF\xFF\xFF\xBF\xC0") or (magic.to_s == " \xFF\xFF\xFF\xFF\xFF\xBF\xC0") # Fuck this shit
      true
    end
    
    def get_addresses(cov, offsiz)
      addresses = []
      if offsiz == 8
        format = 'I<'
      else
        format = 'L<'
      end

      while address = cov.read(offsiz)
        addresses << address.unpack(format)
      end
      addresses.flatten
    end
    
    def cov_filename(pid)
      "#{File.basename @target}.#{pid}.sancov"
    end

    def run_target
      $stdin.reopen File.new @file
      $stdout.reopen @stdout
      $stderr.reopen @stderr
      exec @env, [@target, @target]
    end

    def set_output_files
      @stdout = Tempfile.new ['cobaya', '.stdout']
      @stderr = Tempfile.new ['cobaya', '.stderr']
    end
  end
end
