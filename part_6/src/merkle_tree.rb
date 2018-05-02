class MerkleTree
  attr_accessor :root

  def initialize(data)
    data.push(data.last) unless data.length % 2 == 0
    nodes = data.map { |datum| MerkleNode.new(datum, nil, nil) }
    (0...(data.length / 2 - 1)).each do |i|
      new_level = []
      (0...nodes.length).step(2).each do |j|
        node = MerkleNode.new(nil, nodes[j], nodes[j+1])
        new_level.push(node)
      end
      nodes = new_level
    end
    self.root = nodes[0]
  end
end

class MerkleNode
  attr_accessor :left, :right, :data

  def initialize(data, left, right)
    self.left, self.right = left, right
    self.data = calc_hash(data)
  end

  def calc_hash(data)
    data_hash =
      if left.nil? && right.nil?
        data.to_s
      else
        left.data + right.data
      end
    Crypto.sha256(data_hash)
  end
end
