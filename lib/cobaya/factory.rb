module Cobaya
  class FuzzerFactory
    def from_json(json_str)
      json = JSON.parse json_str

      case json['evolution']
      when 'continuous'
        evo = ContinuousEvolution.new DirCorpus.new json['corpus']
      else
        raise 'Evolution mode unknown'
      end
      
      FuzzingContext.new(
        target: ExecutableTargetContext.new(json['target'].split(' ')),
        corpus: evo,
        crashes: nil
      )
    end
  end
end
