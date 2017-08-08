module Cobaya
  
  ##
  # Corpus location with a file system directory as a backend
  class DirCorpus
    attr_reader :path

    ##
    # Initalizes a new instance from the location path in the file system
    def initialize(path)
      @path = File.absolute_path path
      @individuals = []
      load_individuals
    end

    ##
    # Returns a random sample from the corpus
    def sample
      @individuals.sample
    end

    ##
    # Adds a new sample to the corpus
    def <<(new_indv)
      raise 'TODO'
    end
    
    private

    ##
    # Load the individuals in the list from the files in the location
    def load_individuals
      @individuals = Dir[File.join @path, '**', '*'].map { |file|
        Individual.from_file file
      }
    end
    
  end
end
