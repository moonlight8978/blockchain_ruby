class TXInput
  attr_accessor :tx_id, :v_out, :signature, :public_key

  # @param [Hash]
  #
  # @option attributes [Integer] :tx_id        transaction's id
  # @option attributes [Integer] :v_out        index of output in the transaction
  # @option attributes [String]  :signature    signature
  # @option attributes [String]  :public_key   non-hash public key
  #
  # @return [TXInput]
  def initialize(**attributes)
    self.tx_id = attributes[:tx_id]
    self.v_out = attributes[:v_out]
    self.signature = attributes[:signature]
    self.public_key = attributes[:public_key]
  end

  # Check whether the input has used the input key to sign
  # @param public_key_hash [String] hashed public key
  # @return [Boolean]
  def uses_key?(public_key_hash)
    locking_public_key_hash = Crypto.hash_public_key(public_key)
    locking_public_key_hash == public_key_hash
  end

  # Check if input is in a coinbase transaction
  # @return [Boolean]
  def in_coinbase?
    v_out == -1 && tx_id.nil?
  end
end
