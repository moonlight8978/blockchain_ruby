class Wallet
  attr_reader :public_key, :private_key

  # Bitcoin version
  VERSION = 0

  # Checksum bits
  CHECKSUM_LENGTH = 4

  # Create new wallet address (with private key)
  def initialize
    key_pair = ECDSA.generate_key_pair
    self.private_key, self.public_key = key_pair.values_at(:private_key, :public_key)
  end

  # Return wallet's address encoded in base58
  # @return [String]
  def address
    payload = "#{version}#{public_key_hash}#{checksum}"
    Base58.encode(payload.to_i(16))
  end

  # Bitcoin version
  # @return [String]
  def version
    VERSION.to_s(16).rjust(2, '0')
  end

  # Wallet's hashed public key
  # @return [String]
  def public_key_hash
    Crypto.hash_public_key(public_key)
  end

  # Wallet checksum
  # @return [String]
  def checksum
    first_sha256 = Digest::SHA256.hexdigest(version + public_key_hash)
    second_sha256 = Digest::SHA256.hexdigest(first_sha256)

    second_sha256.slice(0, CHECKSUM_LENGTH)
  end

  # Sign data using ECDSA
  # @param data [String] data to sign
  # @return [String]
  def sign(data)
    key.dsa_sign_asn1(data)
  end

private

  attr_writer :public_key, :private_key

  # Rebuild the key using private key and public key (stored in hexa-bignum)
  # @return [OpenSSL::PKey::EC]
  def key
    ECDSA.build_key(public_key, private_key)
  end
end
