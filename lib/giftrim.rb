require 'tempfile'
require 'subexec'
require 'stringio'
require 'pathname'
require_relative "giftrim/version"
require_relative "core_ext/array"
module Giftrim
  class << self
    attr_accessor :timeout
    attr_accessor :processor
    Giftrim.processor = "gifsicle"

    def frame_number_wanted total_number, target_number
      (0..(total_number-2)).to_a.spread(target_number)
    end
  end

  class Image
    # @return [String] The location of the current working file
    attr_accessor :path

    class << self

      # Modified from MiniMagick, see License_MiniMagick
      # This is the primary loading method used by all of the other class methods.
      #
      # Use this to pass in a stream object. Must respond to Object#read(size) or be a binary string object (BLOBBBB)
      #
      # As a change from the old API, please try and use IOStream objects. They are much, much better and more efficient!
      #
      # Probably easier to use the #open method if you want to open a file or a URL.
      #
      # @param stream [IOStream, String] Some kind of stream object that needs to be read or is a binary String blob!
      # @param ext [String] A manual extension to use for reading the file. Not required, but if you are having issues, give this a try.
      # @return [Image]
      def read(stream, ext = nil)
        if stream.is_a?(String)
          stream = StringIO.new(stream)
        elsif stream.is_a?(StringIO)
          # Do nothing, we want a StringIO-object
        elsif stream.respond_to? :path
          if File.respond_to?(:binread)
            stream = StringIO.new File.binread(stream.path.to_s)
          else
            stream = StringIO.new File.open(stream.path.to_s,"rb") { |f| f.read }
          end
        end

        create(ext) do |f|
          while chunk = stream.read(8192)
            f.write(chunk)
          end
        end
      end

      # Modified from MiniMagick, see License_MiniMagick
      # Opens a specific image file either on the local file system or at a URI.
      #
      # Use this if you don't want to overwrite the image file.
      #
      # Extension is either guessed from the path or you can specify it as a second parameter.
      #
      # If you pass in what looks like a URL, we require 'open-uri' before opening it.
      #
      # @param file_or_url [String] Either a local file path or a URL that open-uri can read
      # @param ext [String] Specify the extension you want to read it as
      # @return [Image] The loaded image
      def open(file_or_url, ext = nil)
        file_or_url = file_or_url.to_s # Force it to be a String... hell or highwater
        if file_or_url.include?("://")
          require 'open-uri'
          ext ||= File.extname(URI.parse(file_or_url).path)
          self.read(Kernel::open(file_or_url), ext)
        else
          ext ||= File.extname(file_or_url)
          File.open(file_or_url, "rb") do |f|
            self.read(f, ext)
          end
        end
      end

      # Modified from MiniMagick, see License_MiniMagick
      # Used to create a new Image object data-copy. Not used to "paint" or that kind of thing.
      #
      # Takes an extension in a block and can be used to build a new Image object. Used
      # by both #open and #read to create a new object! Ensures we have a good tempfile!
      #
      # @param ext [String] Specify the extension you want to read it as
      # @param validate [Boolean] If false, skips validation of the created image. Defaults to true.
      # @yield [IOStream] You can #write bits to this object to create the new Image
      # @return [Image] The created image
      def create(ext = nil, validate = true, &block)
        begin
          tempfile = Tempfile.new(['giftrim_', ext.to_s.downcase])
          tempfile.binmode
          block.call(tempfile)
          tempfile.close

          image = self.new(tempfile.path, tempfile)

          if validate and !image.valid?
            raise Giftrim::Invalid
          end
          return image
        ensure
          tempfile.close if tempfile
        end
      end

    end

    # Modified from MiniMagick, see License_MiniMagick
    # Create a new MiniMagick::Image object
    #
    # _DANGER_: The file location passed in here is the *working copy*. That is, it gets *modified*.
    # you can either copy it yourself or use the MiniMagick::Image.open(path) method which creates a
    # temporary file for you and protects your original!
    #
    # @param input_path [String] The location of an image file
    # @todo Allow this to accept a block that can pass off to Image#combine_options
    def initialize(input_path, tempfile = nil)
      @path = input_path
      @tempfile = tempfile # ensures that the tempfile will stick around until this image is garbage collected.
    end

    # @return [Boolean]
    def valid?
      # TODO
      true
    end

    def run_command command
      sub = Subexec.run(command, :timeout => Giftrim.timeout)
      if sub.exitstatus == 0
        sub.output
      else
        raise Error, "Command (#{command.inspect.gsub("\\", "")}) failed: #{{:status_code => sub.exitstatus, :output => sub.output}.inspect}"
      end
    end

    # Modified from MiniMagick, see License_MiniMagick
    # Writes the temporary file out to either a file location (by passing in a String) or by
    # passing in a Stream that you can #write(chunk) to repeatedly
    #
    # @param output_to [IOStream, String] Some kind of stream object that needs to be read or a file path as a String
    # @return [IOStream, Boolean] If you pass in a file location [String] then you get a success boolean. If its a stream, you get it back.
    # Writes the temporary image that we are using for processing to the output path
    def write(output_to)
      if output_to.kind_of?(String) || !output_to.respond_to?(:write)
        FileUtils.copy_file @path, output_to
        run_command "identify #{output_to}" # Verify that we have a good image
      else # stream
        File.open(@path, "rb") do |f|
          f.binmode
          while chunk = f.read(8192)
            output_to.write(chunk)
          end
        end
        output_to
      end
    end

    def number_of_frames
      command = "#{Giftrim.processor} --info #{@path}"
      output = run_command command
      if output
        first_line = output.lines.first
        number_of_frames = first_line.scan(/\d+[ \t]*images/).first.to_i
      end
      number_of_frames
    end

    def trim
      @outfile = Tempfile.new('giftrim_')
      @outfile.binmode
      @outfile.close

      frames = Giftrim::frame_number_wanted self.number_of_frames, 10
      frames_formatted = frames.map{|frame| "\"##{frame}\""}.join " "
      command = "#{Giftrim.processor} --unoptimize -O2 --no-comments --no-names --delay 20 --same-loopcount --no-warnings --resize-fit '300x300' #{@path} #{frames_formatted} > #{@outfile.path}"
      trim_run_command command
    end

    def trim_with_target_frame_number frame_number
      @outfile = Tempfile.new('giftrim_')
      @outfile.binmode
      @outfile.close

      frames = Giftrim::frame_number_wanted self.number_of_frames, 10
      frames_formatted = frames.map{|frame| "\"##{frame}\""}.join " "
      command = "#{Giftrim.processor} --unoptimize -O2 --no-comments --no-names --delay 20 --same-loopcount --no-warnings #{@path} #{frames_formatted} > #{@outfile.path}"
      trim_run_command command
    end

    private
    def trim_run_command command

      output = run_command command
      if output
        @tempfile = @outfile
        @path = @tempfile.path
        @outfile = nil
      end
      output
    end
  end
end
