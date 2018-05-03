class UTXOSet
  attr_accessor :blockchain

  DB_NAME = 'chainstate'

  # Return new utxo set object
  # @param blockchain [Blockchain] the blockchain
  # @return [UTXOSet]
  def initialize(blockchain)
    self.blockchain = blockchain
  end

  # Reindexing unspent tx outputs
  # @return [void]
  def reindex
    unspent_tx_outputs = blockchain.unspent_transaction_outputs
    grouped_by_tx_id = unspent_tx_outputs

    blockchain.db.transaction do |db|
      db[DB_NAME] = grouped_by_tx_id
      db.commit
    end
  end

  # Get balance of a specific pkey hash
  # @param public_key_hash [String]
  # @return [Integer] balance in satoshis
  def balance_of(public_key_hash)
    unspent_txs = unspent_transaction_outputs_of(public_key_hash)
    unspent_txs.reduce(0) { |sum, tx_out| sum + tx_out.value }
  end

  # Find all unspent tx outputs of a specific pkey hash
  # @param public_key_hash [String]
  # @return [Array<TXOutput>]
  def unspent_transaction_outputs_of(public_key_hash)
    unspent_txs = blockchain.db.transaction { |db| db[DB_NAME] }
    unspent_outputs = unspent_txs.map do |tx_id, outputs|
      outputs.select { |tx_out| tx_out.locked_with?(public_key_hash) }
    end.flatten.compact
  end

  # Find spendable outputs
  # @param public_key_hash [String]
  # @param amount [Integer] currency in satoshis
  # @return [Hash{Symbol => Integer, Hash{String => Integer}}]
  def spendable_outputs_of(public_key_hash, amount)
    unspent_outputs = {}
    accumulated = 0
    unspent_txs = blockchain.db.transaction { |db| db[DB_NAME] }

    unspent_txs.each do |tx_id, outputs|
      outputs.each.with_index do |output, o_idx|
        if output.locked_with?(public_key_hash) && accumulated < amount
          accumulated += output.value
          unspent_outputs[tx_id] ||= []
          unspent_outputs[tx_id] << o_idx
        end
      end
    end

    { accumulated: accumulated, outputs: unspent_outputs }
  end

  # Update the UTXO database after mining a block
  # @param block [Block]
  # @return [void]
  def update(block)
    txs = blockchain.db.transaction { |db| db[DB_NAME] }
    block.transactions.each do |tx|
      new_outputs = tx.v_out
      blockchain.db.transaction do |db|
        db[DB_NAME][tx.id] = new_outputs
        db.commit
      end
      next if tx.coinbase?

      tx.v_in.each do |tx_input|
        outputs = txs[tx_input.tx_id]
        unspents = []
        outputs.each.with_index do |output, o_idx|
          unspents.push(output) if o_idx != tx_input.v_out
        end

        if unspents.length == 0
          blockchain.db.transaction do |db|
            db[DB_NAME].delete(tx_input.tx_id)
            db.commit
          end
        else
          blockchain.db.transaction do |db|
            db[DB_NAME][tx_input.tx_id] = unspents
            db.commit
          end
        end
      end
    end
  end
end
