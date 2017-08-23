require 'spec_helper'

RSpec.describe Cobaya::ExecutableTarget do

  def path(bin)
    `which #{bin.to_s}`.chomp
  end
  
  it "runs true with an empty input" do
    ctx = Cobaya::ExecutableTargetContext.new([path('true')], VoidLogger.new)
    target = Cobaya::ExecutableTarget.new ctx

    target.exec '' do |result|
      expect(result.crash?).to be false
    end
  end

  it "runs cat with input" do
    input = 'test input'
    ctx = Cobaya::ExecutableTargetContext.new([path('cat')], VoidLogger.new)
    target = Cobaya::ExecutableTarget.new ctx

    target.exec input do |result|
      expect(result.crash?).to be false
      expect(result.meta[:output]).to eq input
    end
  end

  it 'runs cat from a file' do
    input = "test input\nsecond line"
    ctx = Cobaya::ExecutableTargetContext.new([path('cat'), '{}'], VoidLogger.new)
    target = Cobaya::ExecutableTarget.new ctx

    target.exec input do |result|
      expect(result.crash?).to be false
      expect(result.meta[:output]).to eq input
    end
  end

  it 'runs cat from a file with command line arguments' do
    input = "test input\nsecond line"
    ctx = Cobaya::ExecutableTargetContext.new([path('cat'), '-u', '{}'], VoidLogger.new)
    target = Cobaya::ExecutableTarget.new ctx

    target.exec input do |result|
      expect(result.crash?).to be false
      expect(result.meta[:output]).to eq input
    end
  end
end
