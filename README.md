[]: {{{1

    File        : README.md
    Maintainer  : Felix C. Stegerman <flx@obfusk.net>
    Date        : 2014-11-22

    Copyright   : Copyright (C) 2014  Felix C. Stegerman
    Version     : v0.1.0

[]: }}}1

[![Gem Version](https://badge.fury.io/rb/open_uri_w_redirect_to_https.png)](https://rubygems.org/gems/open_uri_w_redirect_to_https)

## Description

  open_uri_w_redirect_to_https - open-uri HTTP to HTTPS redirect support patch

  Unfortunately, `open-uri` [does not accept HTTP to HTTPS
  redirects](https://bugs.ruby-lang.org/issues/3719).  This gem
  patches `open` to allow HTTP to HTTPS redirects when requested.

  So instead of:

```bash
$ pry
> require 'open-uri'
> open 'http://github.com'
RuntimeError: redirection forbidden: http://github.com -> https://github.com/
```

  you get:

```bash
$ pry
> require 'open_uri_w_redirect_to_https'
> open 'http://github.com', redirect_to_https: true
=> #<File:/tmp/open-uri...>
```

  or:

```bash
$ pry
> require 'open_uri_w_redirect_to_https'
> OpenURI.redirect_to_https = true   # set default
> open 'http://github.com'
=> #<File:/tmp/open-uri...>
```

## Installation

With bundler:

```ruby
# Gemfile
gem 'open_uri_w_redirect_to_https'
```

Otherwise:

```bash
gem install open_uri_w_redirect_to_https
```

## Caveats

  Monkey-patching is not a very robust way to fix bugs.  Use at your
  own risk.

  Q: why should I prefer this gem to [open_uri_redirections]
  (https://github.com/jaimeiniesta/open_uri_redirections)?
  <br/>
  A: because this one is thread-safe (I hope); other than that, feel
  free to choose either

## Specs & Docs

```bash
rake spec
rake coverage
rake docs
```

## License

  MIT [1].

## References

  [1] MIT License
  --- http://opensource.org/licenses/MIT

[]: ! ( vim: set tw=70 sw=2 sts=2 et fdm=marker : )
