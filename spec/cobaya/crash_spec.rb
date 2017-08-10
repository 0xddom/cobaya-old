require 'spec_helper'

RSpec.describe Cobaya::CrashHandler do
  before :each do
    dir = Dir.mktmpdir
    @handler = Cobaya::CrashHandler.new dir
  end

  it 'stores a new crash' do
    input = "A"*50

    expected_filename = Digest::SHA256.hexdigest input

    @handler << input

    expect(File.exists?(File.join(@handler.path, expected_filename))).to be true
  end
end
