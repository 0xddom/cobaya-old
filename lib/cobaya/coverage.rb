module Cobaya
  class Coverage
    include Singleton

    def initialize
      @addresses = Set.new
    end

    def add(cov)
      cov_set = Set.new cov

      if @addresses.size == 0
        @addresses |= cov_set
        return 1
      else
        diff = cov_set - @addresses
        @addresses |= cov_set
        diff.size
      end
    end
  end

  class CovFile
    attr_reader :addresses

    def self.from_pid(cov_dir, bin, pid, autoload = true)
      filename = File.join cov_dir, "#{File.basename bin}.#{pid}.sancov"
      new filename, autoload
    end
    
    def initialize(path, autoload = true)
      @fd = File.open path, 'rb'
      @addresses = []
      read_addresses if autoload
    end

    def read_addresses
      _, offsiz = get_magic
      format = offsiz == 8 ? 'I<' : 'L<'
      while adress = @fd.read(offsiz)
        @addresses << adress.unpack(format)
      end
      @addresses.flatten!
    end

    private
    def get_magic
      magic = @fd.read 8
      return nil unless valid_magic? magic
      offsiz = magic[0] == 'd' ? 8 : 4

      [magic, offsiz]
    end

    def valid_magic?(_)
      true # TODO
    end
  end
end
