class Input
  getter raw : String

  def initialize(@path : String)
    @raw = File.read(@path)
  end

  def split
    @raw.split("\n")
  end
end
