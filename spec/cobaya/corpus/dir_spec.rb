require 'spec_helper'

RSpec.describe Cobaya::DirCorpus do
  context 'When the location is empty,' do
    before :each do
      dir = Dir.mktmpdir 
      @corpus = Cobaya::DirCorpus.new dir
    end

    it 'returns nil when requested a sample' do
      sample = @corpus.sample

      expect(sample).to be nil
    end

    it 'returns a new sample when added' do
      input = 'AAAAAAAAAAAAAAA'
      @corpus << input
      output = @corpus.sample

      
      expect(output).to eq input
    end
  end

  context 'When the location has a sample,' do
    before :each do
      dir = Dir.mktmpdir
      `echo input1 > #{File.absolute_path dir}/sample1`
      @corpus = Cobaya::DirCorpus.new dir
    end

    it 'returns the sample' do
      sample = @corpus.sample

      expect(sample).to eq "input1\n"
    end

  end
end
