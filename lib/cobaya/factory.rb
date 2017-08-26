module Cobaya
  ##
  # This class exposes methods to create fuzzers from several input types
  #--
  # TODO:
  # - Add tests
  class FuzzerFactory
    
    ##
    # Returns a fuzzer from a json string configuration
    def self.from_json_str(json_str)
      json = JSON.parse json_str
      from_hash json
    end

    ##
    # Returns a fuzzer from a hash table configuration
    def self.from_hash(hash)
      case hash['evolution']
      when 'continuous'
        evo = ContinuousEvolution.new DirCorpus.new hash['corpus']
      else
        raise 'Evolution mode unknown'
      end

      target_ctx = ExecutableTargetContext.new hash['target'].split(' ')
      target = ExecutableTarget.new target_ctx
      FuzzingContext.new(
        target: target,
        corpus: evo,
        crashes: CrashHandler.new(hash['crashes']),
        cpu_aff: (hash['affinity'] || true)
      )
    end
  end
end
