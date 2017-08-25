require 'spec_helper'

RSpec::describe Cobaya::Coverage do
  before :each do
    @cov = Cobaya::Coverage.new
  end

  it 'adds addresses to the coverage' do
    input = Set.new [1,2,3,4]
    @cov.add input

    expect(@cov.addresses).to eq input
  end

  it "don't have duplicate values" do
    input1 = [1,2,3,4]
    input2 = [3,4,5,6]
    expected = Set.new [1,2,3,4,5,6]

    @cov.add input1
    @cov.add input2

    expect(@cov.addresses).to eq expected
  end
end

RSpec::describe Cobaya::CovFile do
  it 'loads a cov file of 64 bit size' do
    file_content = "\xC0\xBF\xFF\xFF\xFF\xFF\xFF\x64 qwertyuasdfghjk"
    fd = Tempfile.new
    fd.write file_content
    fd.rewind

    cov = Cobaya::CovFile.read fd.path

    expect(cov.addresses).to eq([" qwertyu", "asdfghjk"].map {|s| s.unpack 'J!'}.flatten)
  end

  it 'loads a cov file of 32 bit size' do
    file_content = "\xC0\xBF\xFF\xFF\xFF\xFF\xFF\x32 qwertyuasdfghjk"
    fd = Tempfile.new
    fd.write file_content
    fd.rewind

    cov = Cobaya::CovFile.read fd.path

    expect(cov.addresses).to eq([" qwe", "rtyu", "asdf", "ghjk"].map {|s| s.unpack 'I!'}.flatten)
  end
end
