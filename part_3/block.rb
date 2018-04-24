class Block
  # Difficulty of block, use constant for simplicity
  TARGET_BITS = 16

  # previous block's hash of the genesis block, contains 64 zeros
  GENESIS_PREV_HASH = Array.new(64, 0).join('')

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

  # Return block from hash
  # @param block_h [Hash] the hash to deserialize
  # @return [Block]
  # def from_h(block_h)
  #   self.new()
  # end

  # Return block's difficulty
  # @return [Integer] difficulty
  def target_bits
    TARGET_BITS
  end

  # Serialize block
  # @return [Hash] the hash which represents the block
  def to_h
    {
      prev_hash: prev_hash,
      hash: hash,
      data: data,
      nonce: nonce,
      timestamp: timestamp
    }
  end

  # Assign attributes to the block
  # @return [void]
  def assign_attributes(**attributes)
    valid_attributes = [:data, :prev_hash, :timestamp, :hash, :nonce]
    attributes.each do |attribute, value|
      valid_attributes.include?(attribute) && send(:"#{attribute}=", value)
    end
  end

private

  attr_writer :data, :prev_hash, :timestamp
end
