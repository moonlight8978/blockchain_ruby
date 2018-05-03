# Elliptic Curve Digital Signature Algorithm wrapper
module ECDSA
module_function

  # Rebuild the from hexa-bignum public key and private key
  # @param public_key  [String]
  # @param private_key [String]
  # @return [OpenSSL::PKey::EC]
  def build_key(public_key, private_key)
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

  # Generate public-private key pair using ECDSA - prime256v1 curve
  # @return [Hash{Symbol => String}] return keys with `:private_key`, and `:public_key`
  def generate_key_pair
    key = OpenSSL::PKey::EC.new('prime256v1')
    key.generate_key
    public_key = key.public_key.to_bn.to_s(16).downcase
    private_key = key.private_key.to_s(16).downcase

    { private_key: private_key, public_key: public_key }
  end

  # Verify the signature
  # @param signature  [String]
  # @param public_key [String]
  # @param data       [String]
  # @return [Boolean]
  def verify(signature, public_key, data)
    group = OpenSSL::PKey::EC::Group.new('prime256v1')
    key = OpenSSL::PKey::EC.new(group)
    public_bn = OpenSSL::BN.new(public_key, 16)
    public_key = OpenSSL::PKey::EC::Point.new(group, public_bn)
    key.public_key = public_key

    begin
      key.dsa_verify_asn1(data, signature || "")
    rescue OpenSSL::PKey::ECError
      false
    end
  end
end
