class ProofOfWork
  NONCE_RANGE = 0..(2**32 - 1)

  def initialize(block)
    @block = block
    @target = 1 << (256 - block.target_bits)
  end

  def run
    NONCE_RANGE.each do |nonce|
      data = prepare_data(nonce)
      hash = Digest::SHA256.hexdigest(data)
      return [nonce, hash] if (hash.to_i(16) < target)
    end
    throw :not_found
  end

private

  attr_reader :target, :block

  def prepare_data(nonce)
    %W(
      #{block.prev_hash}
      #{block.data}
      #{block.timestamp.to_s(16)}
      #{block.target_bits.to_s(16)}
      #{nonce.to_s(16)}
    ).join('')
  end
end
