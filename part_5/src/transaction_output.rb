class TXOutput
  attr_reader :value, :public_key_hash

  # @param value   [Integer] number of satoshis
  # @param address [String]  address
  #
  # @return [TXOutput]
  def initialize(value, address)
    self.value = value
    lock(address)
  end

  def lock(address)
    payload = Base58.decode(address).to_s(16)
    public_key_hash = payload.slice(0, payload.length - 4)
    self.public_key_hash = public_key_hash
  end

  # Check whether the output is locked with unlocking data
  # @return [Boolean]
  def locked_with?(public_key_hash)
    self.public_key_hash == public_key_hash
  end

private

  attr_writer :value, :public_key_hash
end
