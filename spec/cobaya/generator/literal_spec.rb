require 'spec_helper'

RSpec.describe Cobaya::Literals::True do
  include Cobaya::SexpHelper
  
  it 'generates a true expression' do
    expected = s(:true)

    srand 2346
    lit = Cobaya::LiteralGenerator.random
    result = lit.generate

    expect(result).to eq expected
  end
end

RSpec.describe Cobaya::Literals::False do
  include Cobaya::SexpHelper

  it 'generates a false expression' do
    expected = s(:false)

    srand 234668900947493204
    lit = Cobaya::LiteralGenerator.random
    result = lit.generate

    expect(result).to eq expected
  end
end

RSpec.describe Cobaya::Literals::Nil do
  include Cobaya::SexpHelper
  
  it 'returns a nil expression' do
    expected = s(:nil)

    srand 23466890094749
    lit = Cobaya::LiteralGenerator.random
    result = lit.generate

    expect(result).to eq expected
  end
end

RSpec.describe Cobaya::Literals::Int do
  include Cobaya::SexpHelper
  
  it 'returns an positive integer expression' do
    expected = s(:int, 1277901399)

    srand 0
    lit = Cobaya::LiteralGenerator.random
    result = lit.generate

    expect(result).to eq expected
  end

  it 'returns an negative integer expression' do
    expected = s(:int, -4776661531)

    srand 2346689009474932
    lit = Cobaya::LiteralGenerator.random
    result = lit.generate

    expect(result).to eq expected
  end
end

RSpec.describe Cobaya::Literals::Str do
  include Cobaya::SexpHelper
  
  it 'generates a string expression' do
    expected = s(:str, 'tIq2bNXFGuzaSO3fdxBE4VD')

    srand 23466890094749320
    lit = Cobaya::LiteralGenerator.random
    result = lit.generate

    expect(result).to eq expected
  end
end

RSpec.describe Cobaya::Literals::Sym do
  include Cobaya::SexpHelper
  
  it 'generates a symbol expression' do
    expected = s(:sym, :R3XehBQcn0)

    srand 234668900947493202343423423
    lit = Cobaya::LiteralGenerator.random
    result = lit.generate

    expect(result).to eq expected
  end
end

RSpec.describe Cobaya::LiteralGenerator do
  it 'returns true on literal symbols' do
    expected = [true] * 7

    literals = [:true, :false, :nil, :int, :float, :str, :sym]

    output = literals.map { |lit| Cobaya::LiteralGenerator.literal? lit }

    expect(output).to eq expected
  end

  it 'returns false on non literal symbols' do
    expected = false

    sym = :not_a_literal

    output = Cobaya::LiteralGenerator.literal? sym

    expect(output).to eq expected
  end
end
