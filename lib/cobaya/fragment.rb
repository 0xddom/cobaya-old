class Fragment
  attr_accessor :tree, :filename

  def initialize tree, filename
    @tree = tree
    @filename = filename
  end

  def to_code
    rewriter = ReWriterVisitor.new
    rewriter.process tree
  end
end
