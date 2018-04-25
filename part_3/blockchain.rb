class Blockchain
  # Database file using YAML::Store
  DB_FILE = 'store.yml'

  attr_reader :hash, :db

  # Return the blockchain in db, or create a new blockchain then save to db
  # @return [Blockchain]
  def initialize
    self.db = YAML::Store.new(DB_FILE)

    hash = db.transaction { db.fetch(:l, nil) }

    if hash
      self.hash = hash
    else
      genesis = build_genesis_block
      append_block(genesis)
    end
  end

  # Build a new block with data, prev_hash is required if the block is
  #   genesis block
  #
  # @param data      [String]      the data
  # @param prev_hash [String, nil] it is required if going to build a genesis
  #   block, the hash should be a string contains 64 zeros. Otherwise it should
  #   be nil, the blockchain will automatically pick the most current block's hash
  #
  # @return [Block] new block
  def build_block(data, prev_hash = hash)
    Block.new(data, prev_hash)
  end

  # Append new block to blockchain
  # @param block [Block] the block need to append
  # @return [void] if POW succeed, the block will be saved to the db,
  #   otherwise the block will be skipped
  def append_block(block)
    pow = ProofOfWork.new(block)
    puts "Mining #{block.data}"
    catch :not_found do
      result = pow.run!
      nonce, hash = result.values_at(:nonce, :hash)
      puts "Mining done - #{hash}"
      block.hash = hash
      block.nonce = nonce
      save_block(block)

      self.hash = hash
    end
  end

  # Iterate over the blockchain
  # @yield [block] block in the blockchain
  # @return [void]
  def each(&_block)
    iterator = BlockIterator.new(self)

    until iterator.current_hash == Block::GENESIS_PREV_HASH
      block = iterator.next
      yield(block)
    end
  end

private

  attr_writer :db, :hash

  # Build genesis block
  # @return [Block] the genesis block
  def build_genesis_block
    build_block('Genesis block', Block::GENESIS_PREV_HASH)
  end

  # Save the block to db
  # @return [Block]
  def save_block(block)
    db.transaction do
      db[:l] = block.hash
      db[block.hash] = block
      db.commit
    end
    block
  end
end
