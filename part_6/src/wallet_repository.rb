class WalletRepository
  DB_FILE = 'wallets.yml'

  attr_reader :db

  def initialize
    self.db = YAML::Store.new(DB_FILE)
  end

  def save(wallet)
    db.transaction do
      db[wallet.address] = wallet
    end
  end

  def find(address)
    db.transaction do
      db.fetch(address, nil)
    end
  end

private

  attr_writer :db
end
