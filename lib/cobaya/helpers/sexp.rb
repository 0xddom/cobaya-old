module Cobaya

  ##
  # This module implements an utiliy function that creates AST node instances
  module SexpHelper

    ##
    # Generates an AST node
    #--
    # :reek:UtilityFunction
    # :reek:UncommunicativeMethodName
    def s(*args)
      Parser::AST::Node.new args.shift, args
    end
  end
end
