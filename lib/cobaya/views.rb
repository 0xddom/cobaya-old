module Cobaya
  class View
    include Singleton
    def initialize
      @spinner = TTY::Spinner.new '[:spinner] Fuzzing...', format: :classic
      @pastel = Pastel.new
      @err = @pastel.bold '[', @pastel.red('-'), ']'
      @banner = @pastel.bold ('[' + @pastel.green('+') +
                              '] cobaya ruby fuzzer, version ' +
                              Cobaya::VERSION)
      @info = '[' + @pastel.yellow('!') + ']'
      @ok = '[' + @pastel.green('+') + ']'
    end

    def banner
      puts @banner
      self
    end

    def log_crash(crash)
      puts "#{@err} #{crash.to_s}"
      self
    end

    def info(*msg)
      puts "#{@info} #{msg.join ' '}"
      self
    end

    def ok(*msg)
      puts "#{@ok} #{msg.join ' '}"
      self
    end

    def err(*msg)
      puts "#{@err} #{msg.join ' '}"
      self
    end

    def nl
      puts ''
      self
    end
    
    def step(n)
      @spinner.spin
      print " (Generation #{n})"
      self
    end
  end
end
