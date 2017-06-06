module Cobaya
  class Crash
    attr_reader :status, :path
    attr_accessor :stdout, :stderr, :stdin
    
    def initialize(status)
      @status = status
    end

    def collect(basepath)
      @path = File.join(basepath, "#{Time.now.strftime "%Y%m%d%H%M%S"}-#{@status.pid}")
      Dir.mkdir path, 0700
      `cp #{@stdin} #{File.join path, "stdin"}`
      `cp #{@stdout} #{File.join path, "stdout"}`
      `cp #{@stderr} #{File.join path, "stderr"}`
    end

    def to_s
      sb = "Process #{@status.pid} "
      if @status.exited?
        sb += "exited with code #{@status.exitstatus} "
      end
      if @status.signaled?
        sb += "signaled #{@status.termsig} "
      end
      if @status.coredump?
        sb += "(coredumped)"
      end
      sb
    end
    
  end
end
