module Cobaya
  module Mutation; end
  
  require 'cobaya/evolution/algorithm/base'
  require 'cobaya/evolution/algorithm/continuous'
  require 'cobaya/evolution/crossover/one_point'
  #require 'cobaya/evolution/mutation/fragment'
  #require 'cobaya/evolution/mutation/generative'
  require 'cobaya/evolution/mutation/literal'
  
  require 'cobaya/evolution/fitness'
  require 'cobaya/evolution/individual'
  require 'cobaya/evolution/pool'
end
