require_relative "test_helper"
require File.expand_path('../../lib/giftrim.rb', __FILE__)

describe Giftrim do
  describe "processor" do
    it "must be allowed to change processor or the path of gifsicle" do
      Giftrim.processor = "/usr/local/bin/gifsicle"
      Giftrim.processor.must_equal "/usr/local/bin/gifsicle"
    end
  end

  it "must return frames wanted" do
    frames = Giftrim::frame_number_wanted 30, 20
    frames.length.must_equal 20
    frames.must_equal [0, 1, 2, 4, 5, 7, 8, 10, 11, 13, 14, 15, 17, 18, 20, 21, 23, 24, 26, 27]

    target_number = 20
    (20..40).to_a.each do |i|
      frames = Giftrim::frame_number_wanted i, target_number
      frames.length.must_be :<=, target_number
    end
  end

  describe "when number of frames is smaller than the target number" do
    it "must return frames to be removed" do
      frames = Giftrim::frame_number_wanted 10, 20
      frames.must_equal [0, 1, 2, 3, 4, 5, 6, 7, 8]
    end
  end

  it "must get the number of frames" do
    image = Giftrim::Image.open "test/gifs/0.gif"
    image.number_of_frames.must_equal 10
  end

  it "should trim a gif" do
    Giftrim.timeout = 10

    Dir.glob("test/gifs/*.gif").each do |file|
      image = Giftrim::Image.open file
      image.trim
      image.number_of_frames.must_be :<=, 10
      image.number_of_frames.must_be :>=, 1
      image.write "test/gifs/output/#{File.basename(file)}"
    end
  end
end
