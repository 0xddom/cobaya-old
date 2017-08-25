require 'spec_helper'

RSpec.describe Cobaya::Fuzzer do
  class DummyFitness
    def initialize(interesting = false)
      @interesting = interesting
    end
    def interesting?
      @interesting
    end
  end
  
  class DummyCorpus1
    include Enumerable
    attr_reader :samples
    def initialize(samples)
      @samples = samples
    end
    
    def each
      for sample in @samples.each
        yield sample, DummyFitness.new
      end
    end
    
    def <<(e)
      @samples << e
    end
  end

  class DummyCorpus2
    include Enumerable
    attr_reader :samples

    def initialize(samples, bool = false)
      @samples = samples.map { |e| [e, bool] }
    end

    def each
      for sample, fitness in @samples.map {|s| [s[0], DummyFitness.new(s[1])]}
        yield [sample, fitness]
      end
    end

    def <<(e)
      @samples << [e, true]
    end
  end

  class DummyResult
    attr_reader :meta
    def initialize(crash)
      @crash = crash
      @meta = {}
    end
    def crash?
      @crash
    end
  end
  
  class DummyTarget
    attr_reader :received
    attr_reader :ctx
    
    def initialize(crash)
      @received = []
      @crash = crash

      @ctx = (Class.new do
        def cov?
          false
        end
      end).new
    end
    
    def exec(input)
      @received << input
      yield DummyResult.new(@crash)
    end
  end
  
  it 'performs the fuzzing loop' do
    input = [
      'AAAA',
      'BBBB',
      'CCCC',
      'DDDD'
    ]
    
    corpus = DummyCorpus1.new(input)
    target = DummyTarget.new(false)
    
    ctx = Cobaya::FuzzingContext.new(
      nil,
      [],
      [target],
      VoidLogger.new,
      corpus,
      false
    )
    
    fuzzer = Cobaya::Fuzzer.new ctx

    fuzzer.run


    expect(target.received).to eq corpus.samples
    
  end

  it 'sends crashes to the crashes handler' do
    input = [
      'AAAA',
      'BBBB',
      'CCCC',
      'DDDD'
    ]
    
    corpus = DummyCorpus2.new(input)
    target = DummyTarget.new(true)
    crashes = []
    
    ctx = Cobaya::FuzzingContext.new(
      nil, 
      crashes,
      [target],
      VoidLogger.new,
      corpus,
      false
    )
    
    fuzzer = Cobaya::Fuzzer.new ctx

    fuzzer.run

    expect(crashes).to eq(corpus.samples.map {|e| e[0]})
  end

  it 'sends new inputs to the corpus if they are interesting' do
       input = [
      'AAAA',
      'BBBB',
      'CCCC',
      'DDDD'
    ]
    
    corpus = DummyCorpus2.new(input, true)
    target = DummyTarget.new(true)
    crashes = []
    
    ctx = Cobaya::FuzzingContext.new(
      nil,
      crashes,
      [target],
      VoidLogger.new,
      corpus,
      false
    )
    
    fuzzer = Cobaya::Fuzzer.new ctx

    fuzzer.run

    expect(corpus.samples.map {|e| e[0]}).to eq(input * 2)
  end
end
