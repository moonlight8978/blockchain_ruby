class Block
  TARGET_BITS = 16

  attr_reader :data, :prev_hash, :timestamp, :hash, :nonce

  attr_writer :hash, :nonce

  def initialize(data, prev_hash)
    @timestamp = Time.now.to_i
    @data = data
    @prev_hash = prev_hash
  end

  def target_bits
    TARGET_BITS
  end

private

  attr_writer :data, :prev_hash, :timestamp
end
