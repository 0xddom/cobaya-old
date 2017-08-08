$VERBOSE = nil

require 'cobaya/script'

fuzzer! {
  lang :mruby
  corpus './tests'
  target('/bin/cat') {
    timeout 1
    cov yes
  }
  evolution :continuous
  generation :stochastic
}
