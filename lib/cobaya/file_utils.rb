module Cobaya::FileUtils

  def synced_tmpf(n = 1)
    Array.new(n) do
      f = Tempfile.new
      f.sync = true
      f
    end
  end
  
  def rewind(*files)
    for file in files
      file.rewind
    end
  end
end
