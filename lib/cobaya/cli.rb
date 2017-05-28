require 'thor'
require 'cobaya'

trap("SIGINT") { exit! }

module Cobaya
  class CLI < Thor
    include Thor::Actions

    map %w(-v --version) => :version

    desc 'version', 'cobaya version'
    def version
      puts Cobaya::VERSION
    end

    desc 'fuzz', 'cobaya fuzz'
    def fuzz
      fuzzer = Fuzzer.new
      fuzzer.run
    end

    desc 'mutate [options] FILE', 'cobaya mutate [options] file'
    option :seed, aliases: :s
    option :output, aliases: :o
    option :fragments, required: true, aliases: :f
    option :lang, aliases: :l
    def mutate(file)
      seed = options[:seed] || 0
      lang = options[:lang] || Parsers.default
      collection = FragmentsCollection.instance
      collection.init options[:fragments], lang
      
      mutation = Mutation.from_file file, seed, lang.to_sym

      p mutation.tree
      puts ""
      
      mutation.mutate
    end 
  end
end
