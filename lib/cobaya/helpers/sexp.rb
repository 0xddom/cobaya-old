module Cobaya

  ##
  # This module implements an utiliy function that creates AST node instances
  module SexpHelper

    ##
    # Generates an AST node
    #--
    # :reek:UtilityFunction
    # :reek:UncommunicativeMethodName
    def s(sym, children = [])
      children = [children] unless children.is_a? Array
      Parser::AST::Node.new sym, children
    end
  end
end
