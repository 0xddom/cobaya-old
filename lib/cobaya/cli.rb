require 'thor'
require 'cobaya'

trap("SIGINT") { exit! }

Cobaya::ProcessName.instance.update

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

    desc 'gpfuzz [options] TARGET', 'Starts a fuzzing session using GP'
    option :crashes, aliases: :c
    option :population, aliases: :p
    option :size, aliases: :s
    def gpfuzz(target)
      crashes = options[:crashes] || './crashes'
      population = options[:population] || './population'
      size = options[:size]&.to_i || 100
      fuzzer = GPFuzzer.new target, crashes, population, size
      
      fuzzer.run
    end

    desc 'mutate [options] FILE', 'Mutate a sample in a determinist way'
    option :seed, aliases: :s
    option :output, aliases: :o
    #option :fragments, required: true, aliases: :f
    option :lang, aliases: :l
    def mutate(file)
      seed = options[:seed].to_i || Time.now.to_i
      lang = options[:lang] || Parsers.default
      output = open_stream(options[:output] || '-')
      #collection = FragmentsCollection.instance
      #collection.init options[:fragments], lang

      SRandom.instance.init seed
      
      mutation = Cobaya::Mutators::Generative.from_file file, lang.to_sym
      output.puts Unparser.unparse mutation.mutate
    end

    desc 'crossover [options] PARENT1 PARENT2', 'Crossover two parents to produce new code'
    def crossover(p1_file, p2_file)
      p1 = Individual.from_file p1_file
      p2 = Individual.from_file p2_file

      ch = p1.breed p2
      ch.write_to_io STDOUT
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

    desc 'generate [options] ROOT', 'Generates ruby code'
    option :sexp, aliases: :s, type: :boolean
    def generate(root)
      generator = Cobaya::Generators::Ruby19.new
      rec_generate generator, root, options[:sexp]
    end
    
    private
    def open_stream(file)
      if file == '-'
        STDOUT
      else
        File.open file, 'w'
      end
    end

    def rec_generate(generator, root, sexp)
      tree = generator.generate root.to_sym
      if sexp
        p tree
      else
        begin
          p tree
          puts "=" * 50
          puts Unparser.unparse tree
        rescue Exception => e
          puts "Retry #{e}"
          rec_generate generator, root, sexp
        end
      end
    end
  end
end
