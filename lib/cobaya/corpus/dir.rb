module Cobaya
  
  ##
  # Corpus location with a file system directory as a backend
  class DirCorpus
    attr_reader :path

    ##
    # Initalizes a new instance from the location path in the file system
    def initialize(path)
      @path = File.absolute_path path
      @sha256 = Digest::SHA256
      @individuals = []
      load_individuals
    end

    ##
    # Returns a random sample from the corpus
    def sample
      File.read @individuals.sample unless @individuals.empty?
    end

    ##
    # Adds a new sample to the corpus
    def <<(new_indv)
      filename = File.join path, @sha256.hexdigest(new_indv)
      File.open(filename, 'w') { |fd|
        fd.write new_indv
      }
     
      @individuals << filename
    end
    
    private

    ##
    # Load the individuals in the list from the files in the location
    def load_individuals
      @individuals = Dir[File.join @path, '**', '*'].
                       select { |file| !File.directory? file }
    end
    
  end
end
