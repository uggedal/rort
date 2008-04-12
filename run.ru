$: << File.expand_path("../../halcyon/lib", __FILE__)
$: << File.expand_path("../lib", __FILE__)

require 'rort'

run Rort.start
