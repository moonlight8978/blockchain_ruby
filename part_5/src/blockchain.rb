class Blockchain
  # Database file using YAML::Store
  DB_FILE = 'store.yml'

  attr_reader :hash, :db

  # Return the blockchain in db, or create a new blockchain then save to db
  # @param address [String] Wallet address for genesis block's first transaction
  # @return [Blockchain]
  def initialize(address)
    self.db = YAML::Store.new(DB_FILE)

    hash = db.transaction { db.fetch(:l, nil) }

    if hash
      self.hash = hash
    else
      coinbase_tx = Transaction.new_coinbase(address)
      coinbase_tx.set_id
      genesis = build_genesis_block(coinbase_tx)
      append_block(genesis)
    end
  end

  # Build a new block, prev_hash is required if the block is genesis block
  #
  # @param transactions [Array<Transaction>]
  # @param prev_hash    [String, nil] it is required if going to build a genesis
  #   block, the hash should be a string contains 64 zeros. Otherwise it should
  #   be nil, the blockchain will automatically pick the most current block's hash
  #
  # @return [Block] new block
  def build_block(transactions, prev_hash = hash)
    Block.new(transactions, prev_hash)
  end

  # Append new block to blockchain
  # @param block [Block] the block need to append
  # @return [void] if POW succeed, the block will be saved to the db,
  #   otherwise the block will be skipped
  def append_block(block)
    valid = block.transactions.all? do |tx|
      tx.coinbase? || verify_transaction?(tx)
    end

    unless valid
      puts "Verify block failed!"
      return
    end

    pow = ProofOfWork.new(block)
    catch :not_found do
      result = pow.run!
      nonce, hash = result.values_at(:nonce, :hash)
      puts "Mining done - #{hash}"
      block.hash = hash
      block.nonce = nonce
      save_block(block)

      self.hash = hash
    end
  end

  # Iterate over the blockchain
  # @yield [block] block in the blockchain
  # @return [void]
  def each(&_block)
    iterator = BlockIterator.new(self)

    until iterator.current_hash == Block::GENESIS_PREV_HASH
      block = iterator.next
      yield(block)
    end
  end

  # Get all unspent outputs of a specific address
  # @param public_key_hash [String] wallet address
  # @return [Array<TXOutput>]
  def unspent_transaction_outputs_of(public_key_hash)
    unspent_outputs = []
    unspent_transactions_of(public_key_hash).each do |tx|
      tx.v_out.each do |out|
        unspent_outputs.push(out) if out.locked_with?(public_key_hash)
      end
    end
    unspent_outputs
  end

  # Get all transactions containing unspent outputs
  # @param (see #unspent_transaction_outputs_of)
  # @return [Array<Transaction>]
  def unspent_transactions_of(public_key_hash)
    unspent_txs = []
    spent_tx_outputs = {}

    each do |block|
      block.transactions.each do |tx|
        tx_id = tx.id.to_s
        catch :spent do
          tx.v_out.each.with_index do |out, out_id|
            if spent_tx_outputs[tx_id]
              spent_tx_outputs[tx_id].each do |spent_out|
                throw :spent if spent_out == out_id
              end
            end

            if out.locked_with?(public_key_hash)
              unspent_txs << tx
            end
          end
        end

        unless tx.coinbase?
          tx.v_in.each do |input|
            if input.uses_key?(public_key_hash)
              in_tx_id = input.tx_id.to_s

              spent_tx_outputs[in_tx_id] ||= []
              spent_tx_outputs[in_tx_id] << input.v_out
            end
          end
        end
      end
    end

    unspent_txs
  end

  # Get all transaction outputs available, group by transaction id
  # @param (see #unspent_transaction_outputs_of)
  # @return [Hash{String, nil => Array<TXOutput>}]
  def spendable_outputs_of(public_key_hash)
    result = {}
    unspent_txs = unspent_transactions_of(public_key_hash)
    unspent_txs.each do |tx|
      result[tx.id] = tx.v_out.select { |tx_out| tx_out.locked_with?(public_key_hash) }
    end
    result
  end

  # Get balance of a specific address
  # @param (see #unspent_transaction_outputs_of)
  # @return [Integer] balance in Satoshi
  def balance_of(address)
    payload = Base58.decode(address).to_s(16)
    public_key_hash = payload.slice(0, payload.length - 4)
    unspent_txs = unspent_transaction_outputs_of(public_key_hash)
    unspent_txs.reduce(0) { |sum, tx_out| sum + tx_out.value }
  end

  # Build new transaction
  # @param from   [String] sender's address
  # @param to     [String] receiver's address
  # @param amount [Float]  amount to transfer, at least 0.00000001 BTC
  # @return [Transaction, nil] return nil if amount is invalid or balance is not enough
  def new_utxo(from, to, amount)
    wallet_repo = WalletRepository.new
    wallet = wallet_repo.find(from)

    amount_in_satoshi = (amount / Transaction::SATOSHI).to_i

    total = balance_of(from)
    if total < amount_in_satoshi
      puts "Not enough funds"
      return nil
    end

    v_in = spendable_outputs_of(wallet.public_key_hash).map do |tx_id, tx_outs|
      tx_outs.map.with_index do |tx_out, tx_out_idx|
        TXInput.new(tx_id: tx_id, v_out: tx_out_idx, public_key: wallet.public_key)
      end
    end.flatten

    v_out = [
      TXOutput.new(amount_in_satoshi, to),
      TXOutput.new(total - amount_in_satoshi, from)
    ]

    Transaction.new(v_in: v_in, v_out: v_out).tap do |tx|
      tx.set_id
      sign_transaction(tx, wallet)
    end
  end

  # Find transaction by id
  # @param id [String] transaction's id
  # @return [Transaction, nil]
  def find_transaction(id)
    each do |block|
      tx = block.transactions.detect { |tx| tx.id == id }
      return tx unless tx.nil?
    end
    nil
  end

  # Sign transaction
  # @return [void]
  def sign_transaction(tx, wallet)
    prev_txs = {}

    tx.v_in.each do |tx_input|
      prev_tx = find_transaction(tx_input.tx_id)
      prev_txs[prev_tx.id] = prev_tx
    end

    tx.sign(wallet, prev_txs)
  end

  # Verify transaction
  # @return [Boolean]
  def verify_transaction?(tx)
    return true if tx.coinbase?

    prev_txs = {}

    tx.v_in.each do |tx_input|
      prev_tx = find_transaction(tx_input.tx_id)
      prev_txs[prev_tx.id] = prev_tx
    end

    tx.verify?(prev_txs)
  end

private

  attr_writer :db, :hash

  # Build genesis block
  # @param coinbase_tx [Transaction]
  # @return [Block] the genesis block
  def build_genesis_block(coinbase_tx)
    build_block([coinbase_tx], Block::GENESIS_PREV_HASH)
  end

  # Save the block to db
  # @return [Block]
  def save_block(block)
    db.transaction do
      db[:l] = block.hash
      db[block.hash] = block
      db.commit
    end
    block
  end
end
