module Cobaya

  ##
  # This class stores a unique list of addresses
  class Coverage
    ##
    # A {Set}[https://ruby-doc.org/stdlib-2.4.1/libdoc/set/rdoc/Set.html] that stores the addresses
    attr_reader :addresses

    ##
    # Initializes the instance
    def initialize
      @addresses = Set.new
    end

    ##
    # Adds addresses to the list. The duplicates are discarted
    def add(cov)
      @addresses |= Set.new cov
    end
  end

  ##
  # This class handles the parsing of SanitizerCoverage files
  class CovFile

    ##
    # The address list read from the file
    attr_reader :addresses

    ##
    # Initializes a new instance using the arguments to build the filename
    def self.from_pid(cov_dir, bin, pid)
      filename = File.join cov_dir, "#{File.basename bin}.#{pid}.sancov"
      new filename
    end

    ##
    # Initializes a new instance using the arguments to build the filename.
    # Also reads the addresses before returning the instance
    def self.read_from_pid(cov_dir, bin, pid)
      instance = from_pid(cov_dir, bin, pid)
      instance.load
      return instance
    end

    ##
    # Creates a new instance and automatically reads the file
    def self.read(path)
      instance = new path
      instance.load
      return instance
    end

    ##
    # Initializes a new instance and read the addresses if autoload is set
    def initialize(path)
      @fd = File.open path, 'rb'
      @addresses = []
      @loaded = false
    end

    ##
    # Returns the path of the file
    def path
      @fd.path
    end

    ##
    # Returns whenever the file has been loaded
    def loaded?
      @loaded
    end
    
    ##
    # Reads the addresses from the coverage file
    def load
      @loaded = true
      _, offsiz = parse_header
      format = offsiz == 8 ? 'L!' : 'I!'
      while address = @fd.read(offsiz)
        @addresses << address.unpack(format)
      end
      @addresses.flatten!
    end

    private
    def parse_header
      magic = @fd.read 8
      return nil unless valid_magic? magic
      offsiz = magic[7] == 'd' ? 8 : 4
      
      [magic, offsiz]
    end

    def valid_magic?(_)
      true # TODO
    end
  end
end
