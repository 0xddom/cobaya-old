require 'cobaya'

RSpec.describe Fragment do
  def apply_rewrite_test(parser, code)
    tree = parser.parse code
    fragment = Fragment.new tree, "<fragment>"

    output_code = fragment.to_code

    expect(output_code).to eq(code)
  end
  
  context "in Ruby 1.9" do
    parser = Parsers.get :ruby19
    
    it "1" do
      apply_rewrite_test parser, "1"
    end

    it "1+1" do
      apply_rewrite_test parser, "1+1"
    end

    it "1+1+1" do
      apply_rewrite_test parser, "1+1+1"
    end

    it "!true" do
      apply_rewrite_test parser, "not true"
    end
  end
end
