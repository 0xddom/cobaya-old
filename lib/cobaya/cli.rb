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

    desc 'fuzz [options] TARGET', 'Starts a fuzzing session'
    option :inputs, aliases: :i, required: true
    option :fragments, aliases: :f, required: true
    option :lang, aliases: :l
    option :crashes, aliases: :c
    def fuzz(target)
      lang = options[:lang] || Parsers.default
      crashes = options[:crashes] || './crashes'
      FragmentsCollection.instance.init options[:fragments], lang
      fuzzer = Fuzzer.new target, crashes, options[:inputs], lang
      
      fuzzer.run
    end

    desc 'mutate [options] FILE', 'Mutate a sample in a determinist way'
    option :seed, aliases: :s
    option :output, aliases: :o
    option :fragments, required: true, aliases: :f
    option :lang, aliases: :l
    def mutate(file)
      seed = options[:seed].to_i || Time.now.to_i
      lang = options[:lang] || Parsers.default
      output = open_stream(options[:output] || '-')
      collection = FragmentsCollection.instance
      collection.init options[:fragments], lang

      SRandom.instance.init seed
      
      mutation = Mutation.from_file file, lang.to_sym
      output.puts Unparser.unparse mutation.mutate
    end

    desc 'execute [options] FILE TARGET', 'Execute the sample against the target'
    option :crashes, aliases: :c
    def execute(file, target)
      executor = StdinExecutor.new file, target, (options[:crashes] || './crashes')

      result = executor.execute
      if result
        puts "Process crashed!"
        puts "Information collected in #{result.path}"
      end
    end

    desc 'generate ROOT', 'Generates ruby code'
    def generate(root)
      generator = Cobaya::Generators::Ruby19.new
      tree = generator.generate root.to_sym
      puts Unparser.unparse tree
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
