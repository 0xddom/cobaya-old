module Cobaya
  class Crash
    attr_reader :pid, :path
    attr_accessor :stdout, :stderr, :stdin
    
    def initialize(pid)
      @pid = pid
    end

    def collect(basepath)
      @path = File.join(basepath, "#{Time.now.strftime "%Y%m%d%H%M%S"}-#{pid}")
      Dir.mkdir path, 0700
      `cp #{@stdin} #{File.join path, "stdin"}`
      `cp #{@stdout} #{File.join path, "stdout"}`
      `cp #{@stderr} #{File.join path, "stderr"}`
    end
    
  end
end
