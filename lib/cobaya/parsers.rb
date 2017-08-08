module Cobaya
  class Parsers
    def self.get(version)
      case version
      when :ruby18
        raise "Not supported version"
      when :ruby19
        Parser::Ruby19
      when :ruby20
        raise "Not supported version"
      when :ruby21
        raise "Not supported version"
      when :ruby22
        raise "Not supported version"
      when :ruby23
        raise "Not supported version"
      when :ruby24
        raise "Not supported version"
      else
        raise "Not supported version"
      end
    end
    
    def self.default
      :ruby19
    end
  end
end

module Parser::AST
  class Node
    def leaf?
      not children.any? do |child|
        child.is_a? Parser::AST::Node
      end
    end

    def leaf_count
      if leaf?
        1
      else
        sum = 0
        children.each do |child|
          val = child.is_a? Parser::AST::Node ? child.leaf_count : 1
          sum += val
        end
        sum
      end
    end

    def depth
      if leaf?
        1
      else
        1 + children.map { |child|
          child.is_a? Parser::AST::Node ? child.depth : 1
        }.max
      end
    end
  end
end

Cobaya::AST = Parser::AST
