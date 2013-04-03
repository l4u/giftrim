class Range
  def to_s_with_separator symbol
    "#{self.begin}#{symbol}#{self.end}"
  end
end
