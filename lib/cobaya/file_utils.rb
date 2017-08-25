##
# This module implements methods for handling files
module Cobaya::FileUtils

  ##
  # Creates temporary files with sync turned on
  def synced_tmpf(n = 1)
    Array.new(n) do
      f = Tempfile.new
      f.sync = true
      f
    end
  end

  ##
  # Rewinds all the files in the arguments
  def rewind(*files)
    files.each(&:rewind)
  end
end
