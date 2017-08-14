require 'spec_helper'

RSpec.describe Cobaya::Mutation::LiteralMutation do
  include Cobaya::SexpHelper
  
  it 'mutates an input' do
    srand 2

    expected = s(:dummy, s(:int, -1376693511))
    input = s(:dummy, s(:true))

    mutated = Cobaya::Mutation::LiteralMutation.mutate input

    expect(mutated).to eq expected
  end
end
