class CLI
  # Excute command on the CLI
  # @param command [String]        'createblockchain', 'transfer', 'print', or 'getbalance'
  # @param data    [Array<String>] data to pass to command
  def run(command, data)
    case command
    when 'createblockchain'
      puts "asddas"
      Blockchain.new(data[0])
    when 'transfer'
      transfer(data[0], data[1], data[2])
    when 'print'
      print_blockchain
    when 'getbalance'
      get_balance(data[0])
    end
  end

  # Return the blockchain
  # @return [Blockchain]
  def blockchain
    @blockchain ||= Blockchain.new('Ruby')
  end

  # Create new block
  # @return [void]
  def add_block(data)
    block = blockchain.build_block(data)
    blockchain.append_block(block)
  end

  # Print the blockchain
  # @return [void]
  def print_blockchain
    blockchain.each do |block|
      puts <<~BLOCK
        Prev hash: #{block.prev_hash}
        Data: #{block.hash_transactions}
        Nonce: #{block.nonce}
        Hash: #{block.hash}

      BLOCK
    end
  end

  # @param address [String] wallet address
  # @return [void]
  def get_balance(address)
    balance = blockchain.balance_of(address)
    balance = (balance * Transaction::SATOSHI).to_i
    puts "Balance of #{address}: #{balance} BTC"
  end

  # Transfer btc between 2 addresses
  # @param (see Transaction#new_utxo)
  # @return [void]
  def transfer(from, to, amount)
    tx = blockchain.new_utxo(from, to, amount.to_f)
    if tx
      block = blockchain.build_block([tx])
      blockchain.append_block(block)
    end
  end
end
