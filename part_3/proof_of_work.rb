class ProofOfWork
  # Nonce is 4-byte integer
  NONCE_RANGE = 0..(2**32 - 1)

  # Return new Proof of Work (POW) object for the block
  # @param block [Block] the block which is ready for mining
  # @return [ProofOfWork] new POW object
  def initialize(block)
    @block = block
    @target = 1 << (256 - block.target_bits)
  end

  # Excute the POW process, throw `:not_found` if nonce was not found
  # @return Hash{Symbol => Integer, String} the nonce and hash which made
  #   the block valid
  # @example
  #   result = pow.run!   # => { nonce: ..., hash: ... }
  #   nonce, hash = result.values_at(:nonce, :hash)
  def run!
    NONCE_RANGE.each do |nonce|
      data = prepare_data(nonce)
      hash = Digest::SHA256.hexdigest(data)
      return { nonce: nonce, hash: hash } if (hash.to_i(16) < target)
    end
    throw :not_found
  end

private
  # @overload target
  #   Gets the target
  #   @return [Integer] the target that the block's hash must be less than
  #
  # @overload block
  #   Gets the block
  #   @return [Block]
  attr_reader :target, :block

  # Concat the block's data with the nonce for hashing
  # @param nonce [Integer]
  # @return [String]
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
