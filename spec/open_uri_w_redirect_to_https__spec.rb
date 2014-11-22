# --                                                            ; {{{1
#
# File        : open_uri_w_redirect_to_https__spec.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-11-22
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : MIT
#
# --                                                            ; }}}1

require 'open_uri_w_redirect_to_https'

require 'fakeweb'

FakeWeb.allow_net_connect = false
FakeWeb.register_uri(
  :get, 'http://http-to-http.example.com',
  body: '', status: [301, 'moved'], location: 'http://example.com'
)
FakeWeb.register_uri(
  :get, 'http://http-to-https.example.com',
  body: '', status: [301, 'moved'], location: 'https://example.com'
)
FakeWeb.register_uri(
  :get, 'https://https-to-http.example.com',
  body: '', status: [301, 'moved'], location: 'http://example.com'
)
FakeWeb.register_uri(
  :get, 'https://https-to-https.example.com',
  body: '', status: [301, 'moved'], location: 'https://example.com'
)
FakeWeb.register_uri(:get, 'http://example.com', body: 'HTTP')
FakeWeb.register_uri(:get, 'https://example.com', body: 'HTTPS')

describe 'open' do

  context 'w/ defaults' do                                      # {{{1
    it 'redirects HTTP to HTTP' do
      expect(
        open('http://http-to-http.example.com').read
      ).to eq('HTTP')
    end
    it 'redirects HTTPS to HTTPS' do
      expect(
        open('https://https-to-https.example.com').read
      ).to eq('HTTPS')
    end
    it 'refuses to redirect HTTP to HTTPS' do
      expect {
        open('http://http-to-https.example.com')
      } .to raise_error(RuntimeError, /redirection forbidden/)
    end
    it 'refuses to redirect HTTPS to HTTP' do
      expect {
        open('https://https-to-http.example.com')
      } .to raise_error(RuntimeError, /redirection forbidden/)
    end
  end                                                           # }}}1

  context 'w/ redirect_to_https: true' do                       # {{{1
    it 'redirects HTTP to HTTP' do
      expect(
        open('http://http-to-http.example.com', redirect_to_https: true).read
      ).to eq('HTTP')
    end
    it 'redirects HTTPS to HTTPS' do
      expect(
        open('https://https-to-https.example.com', redirect_to_https: true).read
      ).to eq('HTTPS')
    end
    it 'redirects HTTP to HTTPS' do
      expect(
        open('http://http-to-https.example.com', redirect_to_https: true).read
      ).to eq('HTTPS')
    end
    it 'refuses to redirect HTTPS to HTTP' do
      expect {
        open('https://https-to-http.example.com', redirect_to_https: true)
      } .to raise_error(RuntimeError, /redirection forbidden/)
    end
  end                                                           # }}}1

  context 'w/ redirect_to_https=true' do                        # {{{1
    before(:all) do
      OpenURI.redirect_to_https = true
    end

    after(:all) do
      OpenURI.redirect_to_https = false
    end

    it 'redirects HTTP to HTTP' do
      expect(
        open('http://http-to-http.example.com').read
      ).to eq('HTTP')
    end
    it 'redirects HTTPS to HTTPS' do
      expect(
        open('https://https-to-https.example.com').read
      ).to eq('HTTPS')
    end
    it 'redirects HTTP to HTTPS' do
      expect(
        open('http://http-to-https.example.com').read
      ).to eq('HTTPS')
    end
    it 'refuses to redirect HTTPS to HTTP' do
      expect {
        open('https://https-to-http.example.com')
      } .to raise_error(RuntimeError, /redirection forbidden/)
    end
  end                                                           # }}}1

  context 'w/ threads' do                                       # {{{1
    it 'works' do
      Thread.abort_on_exception = true
      1000.times {
        Thread.new {
          sleep rand
          expect(
            open('http://http-to-http.example.com').read
          ).to eq('HTTP')
        }
        Thread.new {
          sleep rand
          expect(
            open('http://http-to-http.example.com', redirect_to_https: true).read
          ).to eq('HTTP')
        }
        Thread.new {
          sleep rand
          expect(
            open('https://https-to-https.example.com').read
          ).to eq('HTTPS')
        }
        Thread.new {
          sleep rand
          expect(
            open('https://https-to-https.example.com', redirect_to_https: true).read
          ).to eq('HTTPS')
        }
        Thread.new {
          sleep rand
          expect {
            open('http://http-to-https.example.com')
          } .to raise_error(RuntimeError, /redirection forbidden/)
        }
        Thread.new {
          sleep rand
          expect(
            open('http://http-to-https.example.com', redirect_to_https: true).read
          ).to eq('HTTPS')
        }
        Thread.new {
          sleep rand
          expect {
            open('https://https-to-http.example.com')
          } .to raise_error(RuntimeError, /redirection forbidden/)
        }
        Thread.new {
          sleep rand
          expect {
            open('https://https-to-http.example.com', redirect_to_https: true)
          } .to raise_error(RuntimeError, /redirection forbidden/)
        }
      }
    end
  end                                                           # }}}1

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
