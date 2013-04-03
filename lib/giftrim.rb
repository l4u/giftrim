require "mini_magick"
require_relative "giftrim/version"
require_relative "core_ext/array"
require_relative "core_ext/range"
module Giftrim
  def self.frame_number_to_be_removed total_number, target_number
    (0..(total_number-2)).to_a.spread(target_number)
  end

  MiniMagick::Image.module_eval do
    def gif_trim
      self.resize "300x300"
      #self.layers "OptimizePlus" if MiniMagick.processor != :gm
      self.gif_trim_frames 10
    end

    def gif_trim_frames target_number
      n = self["%n"].to_i # number of images in current image sequence

      frames_array = Giftrim.frame_number_to_be_removed(n, target_number)
      frames_range_array  = frames_array.to_ranges.map!{|range|
        range.to_s_with_separator('-')}.join ','

      self.delete frames_range_array if frames_range_array != ''
    end
  end
end
