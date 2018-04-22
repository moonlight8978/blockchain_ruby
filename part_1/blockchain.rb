class Blockchain
  extend Forwardable

  def_delegators :chain, :length, :size

  def initialize
    @chain = []
    chain << create_genesis_block
  end

  def build_block(data)
    Block.new(data, hash)
  end

  def append(block)
    block.calc_hash
    chain << block
  end

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
          Hash: #{block.hash}
        BLOCK
      end.join("\n")}
    BLOCKCHAIN
  end

private

  attr_accessor :chain

  def create_genesis_block
    prev_hash = Array.new(64, 0).join('')
    block = Block.new('Genesis block', prev_hash)
    block.tap do |b|
      b.calc_hash
    end
  end

  def last_block
    chain.last
  end
end
