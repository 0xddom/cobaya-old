module Cobaya
  class Scores
    attr_accessor :structure, :feedback, :pressure
    
    def initialize(structure = 0, feedback = 0, pressure = 0)
      @structure = structure
      @feedback = feedback
      @pressure = pressure
    end

    def total(length)
      (@structure + @feedback) - @pressure * length
    end
  end

  class Fitness
    ExitedMod   = 1.2
    SignaledMod = 2
    CoredumpMod = 1.05

    attr_reader :length
    attr_reader :normalized
    
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
      if cov.nil?
        cov_score = 0
      else
        cov_score = Coverage.instance.add cov
      end
      crash_score = get_crash_modifiers crash
      @scores.feedback = cov_score * crash_score      
    end

    def normalize(max)
      @normalized = score / max
    end

    def interesting?
      false
    end

    private
    def get_crash_modifiers(crash)
      if crash.nil?
        1
      else
        mods = 1

        mods *= ExitedMod if crash.exited?
        mods *= SignaledMod if crash.signaled?
        mods *= CoredumpMod if crash.coredump?
        
        mods
      end
    end
    
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
