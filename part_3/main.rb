require 'yaml/store'
require 'date'
require 'digest'
require 'forwardable'

require_relative 'block'
require_relative 'blockchain'
require_relative 'proof_of_work'
require_relative 'block_iterator'
require_relative 'cli'

blockchain = Blockchain.new
cli = CLI.new(blockchain)

cli.run(ARGV[0], ARGV[1])
