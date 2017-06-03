module Cobaya
  module SexpHelper
    def s(sym, children = [])
      unless children.class.name == "Array"
        children = [children]
      end
      Parser::AST::Node.new sym, children
    end
  end
end
