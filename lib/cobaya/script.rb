require 'cobaya'

require 'cobaya/script/base'
require 'cobaya/script/target'
require 'cobaya/script/fuzzer'

module Cobaya
  class VoidFuzzer
    def run
    end
  end
  
  def fuzzer(builder = FuzzingContextBuilder.new, &block)
    begin
      script = FuzzerScript.new(builder)
      script.instance_eval(&block)
      Fuzzer.new script._builder.build
    rescue ContextBuildError => e
      puts "There where some errors with your configuration:"
      e.errors.each do |error|
        puts "  #{error}"
      end
      VoidFuzzer.new
    end
  end

  def fuzzer!(builder = FuzzingContextBuilder.new, &block)
    fuzzer(builder, &block).run
  end
end

include Cobaya
