module Cobaya
  class View
    def initialize
      @spinner = TTY::Spinner.new '[:spinner] Fuzzing...', format: :classic
      @pastel = Pastel.new
      @crash_header = @pastel.bold '[', @pastel.red('-'), ']'
      @banner = @pastel.bold ('[' + @pastel.green('+') +
                              '] cobaya ruby fuzzer, version ' +
                              Cobaya::VERSION)
      @info = '[' + @pastel.yellow('!') + ']'
      @ok = '[' + @pastel.green('+') + ']'
    end

    def banner
      puts @banner
    end

    def log_crash(crash)
      puts "#{@crash_header} #{crash.to_s}"
    end

    def info(*msg)
      puts "#{@info} #{msg.join ' '}"
    end

    def ok(*msg)
      puts "#{@ok} #{msg.join ' '}"
    end

    def step
      puts @spinner.spin
    end
  end
end
