class Mutation

  attr_accessor :tree
  attr_reader :seed

  def initialize(tree, seed)
    @tree = tree.clone
    @seed = seed
    @collection = FragmentsCollection.instance.collection
  end

  def mutate
    # TODO
  end
  
  def self.from_file(file, seed, language)
    parser = Parsers.get language
    tree = parser.parse File.read file

    Mutation.new tree, seed
  end
end
