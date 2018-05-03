class WalletRepository
  DB_FILE = 'wallets.yml'

  attr_reader :db

  # Create new wallet repository instance
  def initialize
    self.db = YAML::Store.new(DB_FILE)
  end

  # Save wallet to database
  # @param wallet [Wallet]
  # @return [void]
  def save(wallet)
    db.transaction do
      db[wallet.address] = wallet
    end
  end

  # Get the wallet by address
  # @param address [String] Base58 wallet address
  # @return [Wallet, nil]
  def find(address)
    db.transaction do
      db.fetch(address, nil)
    end
  end

private

  attr_writer :db
end
