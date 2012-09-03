long_url
========

Ever wonder where a short url is actually going to send you?

Usage
=====

Ruby:

    LongUrl.call("http://bit.ly/O44xP7")
    # => "https://github.com/jakobwesthoff/colorizer"

Terminal:

    $ long_url "http://bit.ly/O44xP7"
    https://github.com/jakobwesthoff/colorizer
