module Crypto
module_function

  def hash_public_key(public_key)
    pk_sha256 = sha256(public_key)
    pk_rmd160 = rmd160(pk_sha256)

    pk_rmd160
  end

  def sha256(data)
    Digest::SHA256.hexdigest(data)
  end

  def rmd160(data)
    Digest::RMD160.hexdigest(data)
  end
end
