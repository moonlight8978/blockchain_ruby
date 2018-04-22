class Block
  attr_reader :data, :prev_hash, :timestamp, :hash

  def initialize(data, prev_hash)
    @timestamp = Time.now.to_i
    @data = data
    @prev_hash = prev_hash
  end

  def calc_hash
    headers = "#{prev_hash}#{timestamp}#{data}"
    self.hash = Digest::SHA256.hexdigest(headers)
  end

private

  attr_writer :data, :prev_hash, :timestamp, :hash
end
