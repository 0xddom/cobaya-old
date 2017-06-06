module Cobaya
  class Scores
    attr_accessor :structure, :feedback, :pressure
    
    def initialize(structure = 0, feedback = 0, pressure = 0)
      @structure = structure
      @feedback = feedback
      @pressure = pressure
    end

    def total(length)
      (@structure_score + @feedback_score) - @pressure * length
    end
  end
  
  class Fitness
    def initialize(tree)
      @scores = Scores.new
      
      @tree = tree
      @length = calculate_length
      
      options = {
        parser: Ruby19Parser,
        threshold: 1,
        all: true,
        quiet: true,
        continue: true,
        score: true
      }
      
      @flog = ::Flog.new options
    end

    def score
      @scores.total @length
    end
    
    def adjust(pressure)
      @scores.pressure = pressure
    end

    def structure
      @scores.structure = calculate_structure_score
    end

    def feedback(cov, crash)
    end

    private
    def calculate_length
      @tree.leaf_count * @tree.depth / 2 # Somewat related to the area of the triangle
    end

    def flog(code)
      @flog.flog_ruby! code
      @flog.calculate_total_scores
      @flog.calculate
      @flog.total_score
    end

    def calculate_structure_score
      @flog.reset
      begin
        flog Unparser.unparse @tree
      rescue
        0
      end
    end
  end
end
