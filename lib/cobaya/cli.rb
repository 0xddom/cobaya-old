require 'thor'
require 'cobaya'

trap("SIGINT") { exit! }

module Cobaya
  class CLI < Thor
    include Thor::Actions

    map %w(-v --version) => :version

    # Example CLI command. Uncomment the following to set it in action:
    #
    # desc 'commandname [param1|param2]', 'command description' 
    # method_option :countries, :type => :array
    # def commandname(someParam)
    #   # Do things
    # end

    desc 'version', 'cobaya version'
    def version
      puts Cobaya::VERSION
    end
  end
end
