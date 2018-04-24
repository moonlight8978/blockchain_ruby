class Block
  # Difficulty of block, use constant for simplicity
  TARGET_BITS = 16

  attr_reader :data, :prev_hash, :timestamp, :hash, :nonce

  attr_writer :hash, :nonce

  # Return new block
  #
  # @param data       [String] the data
  # @param prev_hash  [String] previous block's hash
  #
  # @return [Block] new block
  def initialize(data, prev_hash)
    @timestamp = Time.now.to_i
    @data = data
    @prev_hash = prev_hash
  end

  # Return block's difficulty
  # @return [Integer] difficulty
  def target_bits
    TARGET_BITS
  end

private

  attr_writer :data, :prev_hash, :timestamp
end
