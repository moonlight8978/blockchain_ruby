class Blockchain
  extend Forwardable

  def_delegators :chain, :length, :size

  def initialize
    @chain = []
    create_genesis_block
  end

  # Build a new block with data, prev_hash is required if the block is genesis block
  def build_block(data, prev_hash = hash)
    Block.new(data, prev_hash)
  end

  def append(block)
    pow = ProofOfWork.new(block)
    puts "Mining #{block.data}"
    catch :not_found do
      nonce, hash = pow.run
      puts "Mining done - #{hash}"
      block.hash = hash
      block.nonce = nonce
      chain << block
    end
  end

  # Get most current block's hash
  def hash
    last_block.hash
  end

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

  def create_genesis_block
    first_hash = Array.new(64, 0).join('')
    block = build_block('Genesis block', first_hash)
    append(block)
  end

  # Get most current block
  def last_block
    chain.last
  end
end
