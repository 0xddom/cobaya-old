module Cobaya
  module SexpHelper
    def s(sym, children = [])
      children = [children] unless children.class.name == "Array"
      Parser::AST::Node.new sym, children
    end
  end
end
