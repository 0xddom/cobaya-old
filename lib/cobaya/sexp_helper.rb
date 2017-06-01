module Cobaya
  module SexpHelper
    def s(sym, *children)
      Parser::AST::Node.new sym, children
    end
  end
end
