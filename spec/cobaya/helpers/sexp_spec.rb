require 'spec_helper'

RSpec.describe Cobaya::SexpHelper do
  include Cobaya::SexpHelper

  it 'creates a node' do
    sexp = s(:val, 1, "str", :sym, true)

    node = Parser::AST::Node.new :val, [1, "str", :sym, true]

    expect(sexp.is_a? Parser::AST::Node).to be true
    expect(sexp).to eq node
  end
end
