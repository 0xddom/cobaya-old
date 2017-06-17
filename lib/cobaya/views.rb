module Cobaya
  class View
    include Singleton

    def initialize
      @spinner = TTY::Spinner.new '[:spinner] :title...', format: :classic
      @pastel = Pastel.new
      @err = @pastel.bold '[', @pastel.red('-'), ']'
      @banner = @pastel.bold ('[' + @pastel.green('+') +
                              '] cobaya ruby fuzzer, version ' +
                              Cobaya::VERSION)
      @info = '[' + @pastel.yellow('!') + ']'
      @ok = '[' + @pastel.green('+') + ']'


      status "Fuzzing" # Default value
    end

    def status(new_status, success = true)
      #@spinner.send(if success then :success else :error end, '')
      @spinner.update title: new_status
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

    def ok(*msg, newline: true)
      print "#{@ok} #{msg.join ' '}"
      nl if newline
      self
    end

    def err(*msg, newline: true)
      print "#{@err} #{msg.join ' '}"
      nl if newline
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
