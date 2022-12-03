class Input
  getter raw : String

  def initialize(@path : String)
    @raw = File.read(@path)
  end

  def split(cleanup = false)
    lines = @raw.split("\n")

    return lines unless cleanup

    lines.reject { |line| line.empty? }
  end
end
