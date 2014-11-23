# --                                                            ; {{{1
#
# File        : open_uri_w_redirect_to_https.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-11-23
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : MIT
#
# --                                                            ; }}}1

require 'open-uri'
require 'thread'

module OpenURI

  RedirectHTTPToHTTPS = { mutex: Mutex.new, default: false }

  class << self
    alias_method :open_uri_orig     , :open_uri
    alias_method :redirectable_orig?, :redirectable?

    # set the `open_uri` `:redirect_to_https` default; thread safe!
    def redirect_to_https=(val)
      (x = RedirectHTTPToHTTPS)[:mutex].synchronize { x[:default] = val }
    end

    # `redirectable?` patch that uses `caller` to determine whether
    # HTTP to HTTPS redirection should be allowed (as well)
    def redirectable?(uri1, uri2)
      if caller(1,4).find { |x| x =~ /redirect_to_https/ } =~ /__WITH__/
        redirectable_w_redirect_to_https? uri1, uri2
      else
        redirectable_orig? uri1, uri2
      end
    end

    # `open_uri` patch that also accepts the `:redirect_to_https`
    # option; when set to `true`, redirections from HTTP to HTTPS are
    # allowed; for example:
    #
    # ```
    # open('http://github.com', redirect_to_https: true)  # works!
    # ```
    #
    # you can set the default using `redirect_to_https=`
    def open_uri(name, *rest, &b)
      r = (o = rest.find { |x| Hash === x }) && o.delete(:redirect_to_https)
      d = (x = RedirectHTTPToHTTPS)[:mutex].synchronize { x[:default] }
      if (r.nil? ? d : r)
        open_uri__WITH__redirect_to_https name, *rest, &b
      else
        open_uri__WITHOUT__redirect_to_https name, *rest, &b
      end
    end

  private

    # allow everything the `redirectable?` method does as well as HTTP
    # to HTTPS
    def redirectable_w_redirect_to_https?(uri1, uri2)
      redirectable_orig?(uri1, uri2) || \
        (uri1.scheme.downcase == 'http' && uri2.scheme.downcase == 'https')
    end

    # just calls open_uri_orig; redirectable? matches __WITH__
    def open_uri__WITH__redirect_to_https(name, *rest, &b)
      open_uri_orig name, *rest, &b
    end

    # just calls open_uri_orig; redirectable? does't match __WITH__
    def open_uri__WITHOUT__redirect_to_https(name, *rest, &b)
      open_uri_orig name, *rest, &b
    end

  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
