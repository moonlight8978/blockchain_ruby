class CLI
  # Return a new CLI object, should be singleton (too lazy to fix)
  # @param blockchain [Blockchain]
  # @return [CLI]
  def initialize(blockchain)
    self.blockchain = blockchain
  end

  # Excute command on the CLI
  # @param command [String] 'add' or 'print'
  # @param data    [String] the block data, required if 'add' command was called
  def run(command, data = nil)
    case command
    when 'add'
      add_block(data)
    when 'print'
      print_blockchain
    end
  end

  # Create new block
  # @return [void]
  def add_block(data)
    block = blockchain.build_block(data)
    blockchain.append_block(block)
  end

  # Print the blockchain
  # @return [void]
  def print_blockchain
    iterator = BlockIterator.new(blockchain)

    while (iterator.current_hash != Block::GENESIS_PREV_HASH) do
      block = iterator.next

      puts <<~BLOCK
        Prev hash: #{block[:prev_hash]}
        Data: #{block[:data]}
        Nonce: #{block[:nonce]}
        Hash: #{block[:hash]}

      BLOCK
    end
  end

private

  attr_accessor :blockchain
end
