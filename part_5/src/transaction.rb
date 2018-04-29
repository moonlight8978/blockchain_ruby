class Transaction
  SATOSHI = 0.00_000_001

  # 50 BTC
  SUBSIDY = (50 / SATOSHI).to_i

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
    v_in = TXInput.new(v_out: -1, signature: data)
    v_out = TXOutput.new(SUBSIDY, to)

    self.new(v_in: [v_in], v_out: [v_out])
  end

  # Set the unique id for transaction
  # @return [void]
  def set_id
    dump = Marshal.dump(self)
    self.id = Crypto.sha256(dump)
  end

  # Check if transaction is coinbase transaction
  # @return [Boolean]
  def coinbase?
    v_in.length == 1 && v_in[0].coinbase?
  end

  def sign(wallet, prev_txs)
    return if coinbase?

    tx_copy = trimmed_copy
    tx_copy.v_in.each.with_index do |tx_input, i_idx|
      prev_tx = prev_txs[tx_input.tx_id]
      tx_copy.v_in[i_idx].signature = nil
      tx_copy.v_in[i_idx].public_key = prev_tx.v_out[tx_input.v_out].public_key_hash
      tx_copy.set_id
      tx_copy.v_in[i_idx].public_key = nil
      signature = wallet.sign(tx_copy.id)
      self.v_in[i_idx].signature = signature
    end
  end

  def trimmed_copy
    inputs = v_in.map do |tx_input|
      TXInput.new(tx_id: tx_input.tx_id, v_out: tx_input.v_out)
    end

    outputs = v_out.map do |tx_output|
      tx_output.dup
    end

    Transaction.new(id: id, v_out: outputs, v_in: inputs)
  end

  def verify?(prev_txs)
    tx_copy = trimmed_copy

    group = OpenSSL::PKey::EC::Group.new('prime256v1')
    key = OpenSSL::PKey::EC.new(group)

    v_in.each.with_index do |tx_input, i_idx|
      prev_tx = prev_txs[tx_input.tx_id]
      tx_copy.v_in[i_idx].signature = nil
      tx_copy.v_in[i_idx].public_key = prev_tx.v_out[tx_input.v_out].public_key_hash
      tx_copy.set_id
      tx_copy.v_in[i_idx].public_key = nil

      public_bn = OpenSSL::BN.new(tx_input.public_key, 16)
      public_key = OpenSSL::PKey::EC::Point.new(group, public_bn)
      key.public_key = public_key

      valid =
        begin
          key.dsa_verify_asn1(tx_copy.id, tx_input.signature || "")
        rescue OpenSSL::PKey::ECError
          false
        end

      return false unless valid
    end

    true
  end

private

  attr_writer :id, :v_in, :v_out
end
