require 'yaml/store'
require 'date'
require 'digest'
require 'forwardable'

require_relative 'block'
require_relative 'blockchain'
require_relative 'proof_of_work'
require_relative 'block_iterator'
require_relative 'transaction'
require_relative 'cli'

cli = CLI.new
command, *data = ARGV
cli.run(command, data)
