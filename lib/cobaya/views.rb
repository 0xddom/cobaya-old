module Cobaya
  class ProcessName
    include Singleton
    
    def initialize
      @status = 'Idle'
      @generation = 0
      @changed = true
    end

    def status=(status)
      @status = status
      @changed = true
    end

    def generation=(generation)
      unless @generation == generation
        @generation = generation
        @changed = true
      end
    end
      
    
    def update
      if @changed
        @changed = false
        $0 = gen_name
      end
    end

    private
    def gen_name
      "cobaya: #{@status} (gen #{@generation})"
    end
  end
  
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

      @process = Cobaya::ProcessName.instance
      status "Fuzzing" # Default value
    end

    def status(new_status, success = true)
      #@spinner.send(if success then :success else :error end, '')
      @spinner.update title: new_status
      @process.status = new_status
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
      @process.generation = n
      @process.update
      @spinner.spin
      print " (Generation #{n})"
      self
    end
  end
end
