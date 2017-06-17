module Cobaya
  class OnePointCrossover
    def initialize(base, other)
      @base = base.tree
      @other = other.tree
    end

    def crossover(retries = 0)
      if retries >= 10_000
        $stderr.puts "Couldn't crossover the sample after 10000 retries. Aborting..."
        exit! 2
      end
      begin
        base_types = Set.new
        other_types = Set.new
        get_types @base, base_types
        get_types @other, other_types
        
        type = choose_type(base_types & other_types)
        choosen_point = choose_point @base, type
        replacement = choose_point @other, type

        Individual.new replace(@base, choosen_point, replacement)
      rescue Exception
        crossover retries + 1
      end
    end
    
    private
    def get_types(tree, types_set)
      return unless tree.class.name == "Parser::AST::Node"
      types_set << tree.type
      tree.children.each do |child|
        get_types child, types_set
      end
    end

    def choose_type(types)
      types.to_a.sample
    end

    def choose_point(tree, type, points = [])
      return unless tree.class.name == "Parser::AST::Node"
      if tree.type == type
        points << tree
      end
      tree.children.each do |child|
        choose_point child, type, points
      end
      points.sample
    end

    def replace(tree, point, replacement)
      return tree unless tree.class.name == "Parser::AST::Node"
      if tree == point
        replacement
      else
        copy = tree.children.dup
        copy.map! do |e|
          replace e, point, replacement
        end
        tree.updated tree.type, copy
      end
    end
  end
end
