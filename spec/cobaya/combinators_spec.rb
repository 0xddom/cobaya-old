require 'cobaya'

RSpec.describe Cobaya::Combinators::Literal do
  include Cobaya::Combinators

  before(:each) do
    @context = Cobaya::GeneratorContext.new
  end
  
  it "generates a correct unary terminal" do
    true_terminal = terminal :true
    expect(true_terminal.generate).to eq(Parser::AST::Node.new :true)
  end
end

RSpec.describe Cobaya::Combinators::Terminal do
  include Cobaya::Combinators
  include Cobaya::Generators

  before(:each) do
    @context = Cobaya::GeneratorContext.new
  end
  
  it "generates a correct binary terminal" do
    class IntFixture
      def generate
        1
      end
    end
    
    int_terminal = terminal :int, IntFixture.new
    gen = int_terminal.generate

    expect(gen).to eq(Parser::AST::Node.new :int, [1])
  end
end

RSpec.describe Cobaya::Generators::NumGen do
  it "generates a number" do
    srand 1234
    generator = Cobaya::Generators::NumGen.new 10
    expect(generator.generate).to eq 3
  end

  it "generates a negative number" do
    srand 2
    generator = Cobaya::Generators::NumGen.new 10
    expect(generator.generate).to eq(-8)
  end

  it "generates a positive number" do
    srand 2
    generator = Cobaya::Generators::NumGen.new 10, false
    expect(generator.generate).to eq 8
  end
end

RSpec.describe Cobaya::Combinators::Any do
  include Cobaya::Combinators
  
  before(:each) do
    @context = Cobaya::GeneratorContext.new
  end

  it 'generates the children' do
    srand 1234
    terminal :a
    terminal :b
    terminal :c
    terminal :d

    expected = Parser::AST::Node.new :d
    any_g = any :a, :b, :c, :d

    expect(any_g.generate).to eq expected
  end

  it 'returns the symbol when the children is not a terminal or non_terminal' do
    srand 1234
    terminal :a
    terminal :b
    terminal :c

    expected = :d
    any_g = any :a, :b, :c, :d

    expect(any_g.generate).to eq expected
  end
end

RSpec.describe Cobaya::Combinators::Optional do
  include Cobaya::Combinators

  before :each do
    @context = Cobaya::GeneratorContext.new
  end

  it 'should not be included' do
    srand 7
    opt_g = optional :a
    expect(opt_g.include?).to be false
  end

  it 'generates the child' do
    terminal :a
    opt_g = optional :a
    expected = Parser::AST::Node.new :a
    expect(opt_g.generate).to eq expected
  end

  it 'returns the symbol' do
    opt_g = optional :a
    expected = :a
    expect(opt_g.generate).to eq expected
  end
end

RSpec.describe Cobaya::Combinators::Nilable do
  include Cobaya::Combinators

  before :each do
    @context = Cobaya::GeneratorContext.new
  end

  it 'generates a nil' do
    srand 7
    nil_g = nilable :a
    expect(nil_g.generate).to be nil
  end

  it 'generates the child' do
    srand 2
    terminal :a
    nil_g = nilable :a
    expected = Parser::AST::Node.new :a
    expect(nil_g.generate).to eq expected
  end

  it 'returns the symbol' do
    srand 2
    nil_g = nilable :a
    expected = :a

    expect(nil_g.generate).to eq expected
  end
end

RSpec.describe Cobaya::Combinators::Multiple do
  include Cobaya::Combinators

  before :each do
    @context = Cobaya::GeneratorContext.new
    @context.max_child = 3
  end

  it 'generates the children' do
    srand 1
    terminal :a
    terminal :b
    terminal :c
    
    mul_g = multiple :a, :b, :c
    expected = [Parser::AST::Node.new(:a), Parser::AST::Node.new(:a)]

    expect(mul_g.generate).to eq expected
  end

  it 'dont generate a not found node' do
    srand 1
    mul_g = multiple :a, :b, :c
    expected = []

    expect(mul_g.generate).to eq expected
  end

  it 'generate the symbol using #force!' do
    srand 1
    mul_g = multiple(:a, :b, :c).force!
    expected = [:a, :a]

    expect(mul_g.generate).to eq expected
  end
  
end

RSpec.describe Cobaya::Combinators::Group do
  include Cobaya::Combinators

  before :each do
    @context = Cobaya::GeneratorContext.new
  end

  it 'generates the children in the group' do
    terminal :a
    terminal :b
  
    grp = group :a, :b
    expected = [Parser::AST::Node.new(:a), Parser::AST::Node.new(:b)]

    expect(grp.generate).to eq expected
  end
end

RSpec.describe Cobaya::Combinators::NonTerminal do
  include Cobaya::Combinators
  include Cobaya::SexpHelper

  before :each do
    @context = Cobaya::GeneratorContext.new
  end

  it 'generates the children in the group' do
    terminal :a
    terminal :b

    nt = non_terminal :c, :a, :a, :b

    expected = s :c, [s(:a), s(:a), s(:b)]

    expect(nt.generate).to eq expected
  end

  it 'generates symbols when children is not found' do
    terminal :a

    nt = non_terminal :c, :a, :a, :b

    expected = s :c, [s(:a), s(:a), :b]

    expect(nt.generate).to eq expected
  end

  it 'generates the children in the group' do
    srand 7
    terminal :a
    terminal :b

    nt = non_terminal :c, :a, nilable(:a), :b

    expected = s :c, [s(:a), nil, s(:b)]

    expect(nt.generate).to eq expected
  end
end
