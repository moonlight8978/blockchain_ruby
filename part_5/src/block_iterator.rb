class BlockIterator
  attr_reader :current_hash

  # Return an iterator to iterate over the blockchain
  # @param blockchain [Blockchain] The blockchain over which we need to iterate
  # @return [BlockIterator]
  def initialize(blockchain)
    self.db = blockchain.db
    self.current_hash = blockchain.hash
  end

  # Return the next block, first call on this method will result in first block
  # @return [Block] next block or first block
  def next
    block = db.transaction { db.fetch(current_hash, nil) }
    self.current_hash = block.prev_hash
    block
  end

private

  attr_reader :db

  attr_writer :db, :current_hash
end
