require 'date'
require 'digest'
require 'forwardable'
require_relative 'block'
require_relative 'blockchain'
require_relative 'proof_of_work'

blockchain = Blockchain.new

block = blockchain.build_block('Block 1')
blockchain.append(block)

block = blockchain.build_block('Block 2')
blockchain.append(block)

blockchain.log
