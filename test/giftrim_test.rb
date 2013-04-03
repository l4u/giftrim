require_relative "test_helper"
require File.expand_path('../../lib/giftrim.rb', __FILE__)

describe Giftrim do
  it "must return frames to be removed" do
    target_number = 20

    frames = Giftrim::frame_number_to_be_removed 30, 20
    frames.must_equal [2, 5, 8, 11, 14, 17, 20, 23, 26, 28]
    frames.length.must_equal 10

    (20..40).to_a.each do |i|
      frames = Giftrim::frame_number_to_be_removed i, target_number
      frames.length.must_equal(i - target_number)
    end
  end

  describe "when number of frames is smaller than the target number" do
    it "must return frames to be removed" do
      frames = Giftrim::frame_number_to_be_removed 10, 20
      frames.must_equal []
    end
  end

  it "must return frame range" do
    frames = [1,2,3,5,6,8,9,10]
    string = frames.to_ranges.map{|range| range.to_s_with_separator('-')}.join(',')
    string.must_equal "1-3,5-6,8-10"
  end

  it "should trim a gif" do
    #MiniMagick.processor = :gm

    Dir.glob("test/gifs/*.gif").each do |file|
      image = MiniMagick::Image.open file
      image.gif_trim
      image["%n"].to_i.must_be :<=, 10
      image.write "test/gifs/output/#{File.basename(file)}"
    end
  end
end
