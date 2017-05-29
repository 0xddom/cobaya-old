require 'thor'
require 'cobaya'

trap("SIGINT") { exit! }

module Cobaya
  class CLI < Thor
    include Thor::Actions

    map %w(-v --version) => :version

    desc 'version', 'Returns the current version'
    def version
      puts Cobaya::VERSION
    end

    desc 'fuzz', 'Start a fuzzing session'
    def fuzz
      fuzzer = Fuzzer.new
      fuzzer.run
    end

    desc 'mutate [options] FILE', 'Mutate a sample in a determinist way'
    option :seed, aliases: :s
    option :output, aliases: :o
    option :fragments, required: true, aliases: :f
    option :lang, aliases: :l
    def mutate(file)
      seed = (options[:seed] || 0).to_i
      lang = options[:lang] || Parsers.default
      output = open_stream(options[:output] || '-')
      collection = FragmentsCollection.instance
      collection.init options[:fragments], lang

      SRandom.instance.init seed
      
      mutation = Mutation.from_file file, lang.to_sym
      output.puts Unparser.unparse mutation.mutate
    end

    private
    def open_stream(file)
      if file == '-'
        STDOUT
      else
        File.open file, 'w'
      end
    end
  end
end
