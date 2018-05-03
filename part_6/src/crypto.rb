# Digest wrapper
module Crypto
module_function

  # Hash the public key by using RMD160 on SHA256 hashed public key
  # @param public_key [String]
  # @return [String] hashed public key
  def hash_public_key(public_key)
    pk_sha256 = sha256(public_key)
    rmd160(pk_sha256)
  end

  # Hash the data by SHA256 hashing algorithm
  # @param data [String]
  # @return [String]
  def sha256(data)
    Digest::SHA256.hexdigest(data)
  end

  # Hash the data by RMD160 hashing algorithm
  # @param (see#sha256)
  # @return (see#sha256)
  def rmd160(data)
    Digest::RMD160.hexdigest(data)
  end
end
