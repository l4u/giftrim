# GifTrim

Provide convenient methods for GIF optimizations using gifsicle

Tested on the following Rubies: MRI 1.9.3, 2.0.0, Rubinius, JRuby (1.9 mode).

[![Gem Version](https://badge.fury.io/rb/giftrim.png)](http://badge.fury.io/rb/giftrim)
[![Build Status](https://secure.travis-ci.org/l4u/giftrim.png?branch=master)](http://travis-ci.org/l4u/giftrim)
[![Coverage Status](https://coveralls.io/repos/l4u/giftrim/badge.png?branch=master)](https://coveralls.io/r/l4u/giftrim)
[![Code Climate](https://codeclimate.com/github/l4u/giftrim.png)](https://codeclimate.com/github/l4u/giftrim)
[![Dependency Status](https://gemnasium.com/l4u/giftrim.png)](https://gemnasium.com/l4u/giftrim)

## Installation

Add this line to your application's Gemfile:

    gem "giftrim"

## Usage

### Resize to 300x300, and trim to 10 frames
```
image = Giftrim::Image.open "input.gif"
image.trim
image.write "output.gif"
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

See LICENSE.txt and LICENSE_MiniMagick.txt

The Testing GIF was retrieved from
http://commons.wikimedia.org/wiki/File:Lightnings_sequence_2_animation.gif
licensed under [Creative Commons Attribution-Share Alike 2.5 Generic](http://creativecommons.org/licenses/by-sa/2.5/deed.en) license

## Alternatives

The first version was at the branch *minimagick*. It adds frames trimming
methods to MiniMagick::Image. However, from my tests mogrify is not accepting
`-delete ranges`, such as `-delete 1-2,4,6`.

This version uses gifsicle instead of ImageMagick which allows selecting frames
to be included.
