# Giftrim

Extends MiniMagick to provide convenient wrappers for GIF optimizations

## Installation

Add this line to your application's Gemfile:

    gem 'giftrim'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install giftrim

## Usage

### Resize to 300x300, run OptimizePlus and trim to 10 frames
```
image = MiniMagick::Image.open "input.gif"
image.gif_trim
image.write "output.gif"
```

### Trim to 20 frames
```
image = MiniMagick::Image.open "input.gif"
image.gif_trim_frames 20
image.write "output.gif"
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Alternatives

Use gifsicle wrapped by image_optim
