class Wallet
  attr_reader :public_key, :private_key

  VERSION = 0
  CHECKSUM_LENGTH = 4

  def initialize
    key_pair = generate_key_pair
    self.private_key, self.public_key = key_pair.values_at(:private_key, :public_key)
  end

  def address
    payload = "#{version}#{public_key_hash}#{checksum}"
    Base58.encode(payload.to_i(16))
  end

  def version
    VERSION.to_s(16).rjust(2, '0')
  end

  def public_key_hash
    Crypto.hash_public_key(public_key)
  end

  def checksum
    first_sha256 = Digest::SHA256.hexdigest(version + public_key_hash)
    second_sha256 = Digest::SHA256.hexdigest(first_sha256)

    second_sha256.slice(0, CHECKSUM_LENGTH)
  end

  def sign(data)
    key.dsa_sign_asn1(data)
  end

private

  attr_writer :public_key, :private_key

  def generate_key_pair
    key = OpenSSL::PKey::EC.new('prime256v1')
    key.generate_key
    public_key = key.public_key.to_bn.to_s(16).downcase
    private_key = key.private_key.to_s(16).downcase

    { private_key: private_key, public_key: public_key }
  end

  def key
    group = OpenSSL::PKey::EC::Group.new('prime256v1')
    key = OpenSSL::PKey::EC.new(group)

    public_bn = OpenSSL::BN.new(public_key, 16)
    private_bn = OpenSSL::BN.new(private_key, 16)
    public_key = OpenSSL::PKey::EC::Point.new(group, public_bn)

    key.tap do
      key.public_key = public_key
      key.private_key = private_bn
    end
  end
end
