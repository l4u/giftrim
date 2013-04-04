# From http://stackoverflow.com/questions/11903839/algorithm-to-spread-selection-over-a-fixed-size-array
class Array
  def spread(n)
    step = self.length.to_f / n
    array = (0..(n - 1)).to_a.collect{|i| self[(i * step)]}.uniq
  end
end
