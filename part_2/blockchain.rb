class Blockchain
  extend Forwardable

  # @!method length, size
  def_delegators :chain, :length, :size

  # Return new blockchain with a genesis block
  # @return [Blockchain] new blockchain
  def initialize
    @chain = []
    create_genesis_block
  end

  # Build a new block with data, prev_hash is required if the block is
  #   genesis block
  #
  # @param data      [String]      the data
  # @param prev_hash [String, nil] it is required if going to build a genesis
  #   block, the hash should be '000...00' (64 zeroes). Otherwise it should
  #   be nil, the blockchain will automatically pick the most current block's hash
  #
  # @return [Block] new block
  def build_block(data, prev_hash = hash)
    Block.new(data, prev_hash)
  end

  # Append new block to blockchain
  # @param block [Block] the block to append
  # @return [void] if POW succeed, the block will append to the blockchain,
  #   otherwise the block will be skipped
  def append(block)
    pow = ProofOfWork.new(block)
    puts "Mining #{block.data}"
    catch :not_found do
      result = pow.run!
      nonce, hash = result.values_at(:nonce, :hash)
      puts "Mining done - #{hash}"
      block.hash = hash
      block.nonce = nonce
      chain << block
    end
  end

  # Get most current block's hash
  # @return [String] most current block's hash
  def hash
    last_block.hash
  end

  # Logger
  # @return [void]
  def log
    puts <<~BLOCKCHAIN

      Blockchain length: #{length}
      Most current block's hash: #{hash}

      #{chain.map do |block|
        <<~BLOCK
          Prev hash: #{block.prev_hash}
          Data: #{block.data}
          Nonce: #{block.nonce}
          Hash: #{block.hash}
        BLOCK
      end.join("\n")}
    BLOCKCHAIN
  end

private

  attr_accessor :chain

  # Build then append genesis block
  # @return [void]
  def create_genesis_block
    first_hash = Array.new(64, 0).join('')
    block = build_block('Genesis block', first_hash)
    append(block)
  end

  # Get most current block
  # @return [Block] most current block
  def last_block
    chain.last
  end
end
