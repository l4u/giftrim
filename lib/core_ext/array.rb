# From http://stackoverflow.com/questions/11903839/algorithm-to-spread-selection-over-a-fixed-size-array
class Array
  def spread(n)
    step = self.length.to_f / (n - 1)
    self - ((0..(n-2)).to_a.collect{|i| self[i * step]})
  end

  def to_ranges
    ranges = self.sort.uniq.inject([]) do |spans, n|
      if spans.empty? || spans.last.last.succ != n
        spans + [n..n]
      else
        spans[0..-2] + [spans.last.first..n]
      end
    end
    ranges
  end
end
