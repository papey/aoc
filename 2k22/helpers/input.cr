class Input
  getter raw : String

  def initialize(@path : String)
    @raw = File.read(@path)
  end

  def lines(cleanup = false)
    @raw.split("\n", remove_empty: cleanup)
  end
end
