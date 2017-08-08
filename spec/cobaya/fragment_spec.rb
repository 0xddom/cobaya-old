require 'spec_helper'

RSpec.describe Cobaya::Fragment do
  def apply_rewrite_test(parser, code)
    tree = parser.parse code
    fragment = Cobaya::Fragment.new tree, "<fragment>"

    output_code = fragment.to_code

    expect(output_code).to eq(code)
  end
  
  context "in Ruby 1.9" do
  end
end
