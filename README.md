[]: {{{1

    File        : README.md
    Maintainer  : Felix C. Stegerman <flx@obfusk.net>
    Date        : 2014-11-26

    Copyright   : Copyright (C) 2014  Felix C. Stegerman
    Version     : v0.1.3

[]: }}}1

[![Gem Version](https://badge.fury.io/rb/open_uri_w_redirect_to_https.png)](https://rubygems.org/gems/open_uri_w_redirect_to_https)
[![Build Status](https://travis-ci.org/obfusk/open_uri_w_redirect_to_https.png)](https://travis-ci.org/obfusk/open_uri_w_redirect_to_https)

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
> OpenURI.w_redirect_to_https { open 'http://github.com' }
  # dynamically scoped in current thread
=> #<File:/tmp/open-uri...>
```

  or:

```bash
$ pry
> require 'open_uri_w_redirect_to_https'
> OpenURI.redirect_to_https = true   # set global default
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

  Q: Why should I prefer this gem to [open_uri_redirections]
  (https://github.com/jaimeiniesta/open_uri_redirections)?
  <br/>
  A: Now that open_uri_redirections (>= 0.2.0) is thread-safe, feel
  free to choose either based on your needs.  This gem supports global
  and dynamic defaults, wherease open_uri_redirections supports HTTPS
  to HTTP (unsafe) redirects.

  NB: this gem internally uses thread-local variables like
  `Thread.current[:__open_uri_w_redirect_to_https__]`.

## Specs & Docs

```bash
rake spec
rake coverage
rake docs
```

## TODO

* specs: (can we) test `redirect_to_https=true` w/ threads?
* thread-safe spec: (can we) make it no longer brittle?

## License

  MIT [1].

## References

  [1] MIT License
  --- http://opensource.org/licenses/MIT

[]: ! ( vim: set tw=70 sw=2 sts=2 et fdm=marker : )
