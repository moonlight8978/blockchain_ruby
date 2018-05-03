class Block
  # Difficulty of block, use constant for simplicity
  TARGET_BITS = 16

  # previous block's hash of the genesis block, contains 64 zeros
  GENESIS_PREV_HASH = Array.new(64, 0).join('')

  attr_reader :transactions, :prev_hash, :timestamp, :hash, :nonce

  attr_writer :hash, :nonce

  # Return new block
  #
  # @param transactions [Array<Transaction>]
  # @param prev_hash    [String] previous block's hash
  #
  # @return [Block] new block
  def initialize(transactions, prev_hash)
    self.timestamp = Time.now.to_i
    self.prev_hash = prev_hash
    self.transactions = transactions
  end

  # Return block's difficulty
  # @return [Integer] difficulty
  def target_bits
    TARGET_BITS
  end

  # Get unique hash of transactions
  # @return [String] 256-bit hash
  def hash_transactions
    tx_ids = transactions.map(&:id).join('')
    Crypto.sha256(tx_ids)
  end

private

  attr_writer :transactions, :prev_hash, :timestamp
end
