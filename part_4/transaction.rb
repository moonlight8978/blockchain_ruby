class Transaction
  SATOSHI = 0.00_000_001

  # 50 BTC
  SUBSIDY = 50 / SATOSHI

  attr_reader :id, :v_in, :v_out

  # Return new transaction
  #
  # @param [Hash] attributes the attributes to build a transaction
  # @option attributes [String]       :id     transaction's id
  # @option attributes [Array<TXIn>]  :v_in   transaction's inputs
  # @option attributes [Array<TXOut>] :v_out  transaction's outputs
  #
  # @return [Transaction]
  def initialize(**attributes)
    self.id = attributes[:id]
    self.v_in = attributes[:v_in]
    self.v_out = attributes[:v_out]
  end

  # Return new Coinbase transaction (first tx), it doesn't require v_in
  # @param to [String] user wallet address
  # @return [Transaction]
  def self.new_coinbase(to)
    data = "Reward to #{to}"
    v_in = TXInput.new(v_out: -1, script_sig: data)
    v_out = TXOutput.new(SUBSIDY, to)

    self.new(v_in: [v_in], v_out: [v_out])
  end

  # Set the unique id for transaction
  # @return [void]
  def set_id
    dump = Marshal.dump(self)
    self.id = Digest::SHA256.hexdigest(dump)
  end

  # Check if transaction is coinbase transaction
  # @return [Boolean]
  def coinbase?
    v_in.length == 1 && v_in[0].coinbase?
  end

private

  attr_writer :id, :v_in, :v_out
end

class TXInput
  attr_reader :tx_id, :v_out, :script_sig

  # @param [Hash]
  #
  # @option attributes [Integer] :tx_id       transaction's id
  # @option attributes [Integer] :v_out       index of output in the transaction
  # @option attributes [String]  :script_sig  signature - wallet address for simplicity
  #
  # @return [TXInput]
  def initialize(**attributes)
    self.tx_id = attributes[:tx_id]
    self.v_out = attributes[:v_out]
    self.script_sig = attributes[:script_sig]
  end

  # Check if this input can unlock the output with the unlocking data
  # @return [Boolean]
  def can_unlock_output_with?(unlocking_data)
    script_sig == unlocking_data
  end

  # Check if input is in a coinbase transaction
  # @return [Boolean]
  def coinbase?
    v_out == -1 && tx_id.nil?
  end

private

  attr_writer :tx_id, :v_out, :script_sig
end

class TXOutput
  attr_reader :value, :script_pub_key

  # @param value          [Integer] number of satoshis
  # @param script_pub_key [String]  public key - wallet address for
  #
  # @return [TXOutput]
  def initialize(value, script_pub_key)
    self.value = value
    self.script_pub_key = script_pub_key
  end

  # Check if this output can be unlocked with unlocking data
  # @return [Boolean]
  def can_be_unlocked_with?(unlocking_data)
    script_pub_key == unlocking_data
  end

private

  attr_writer :value, :script_pub_key
end
