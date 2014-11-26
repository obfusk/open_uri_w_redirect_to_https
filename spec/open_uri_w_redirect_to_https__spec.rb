# --                                                            ; {{{1
#
# File        : open_uri_w_redirect_to_https__spec.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-11-26
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
FakeWeb.register_uri(
  :get, 'http://http-to-http-to-https.example.com',
  body: '', status: [301, 'moved'],
  location: 'http://http-to-https.example.com'
)
FakeWeb.register_uri(:get, 'http://example.com', body: 'HTTP')
FakeWeb.register_uri(:get, 'https://example.com', body: 'HTTPS')

class << OpenURI
  alias_method :open_uri_orig__, :open_uri_orig
end

describe 'open' do

  context 'does not break anything' do                          # {{{1
    it 'and passes arguments on' do
      expect(OpenURI).to receive(:open_uri_orig) \
        .with(kind_of(URI), { 'User-Agent' => 'foo' })
      open('http://http-to-https.example.com',
        redirect_to_https: true, 'User-Agent' => 'foo')
    end
    it 'does not affect other calls to redirectable?' do
      expect(
        open('http://http-to-http.example.com') do |x|
          OpenURI.redirectable?(URI.parse('http://foo'),
                                URI.parse('https://foo'))
        end
      ).to be_falsey
      expect(
        open('http://http-to-https.example.com',
              redirect_to_https: true) do |x|
          OpenURI.redirectable?(URI.parse('http://foo'),
                                URI.parse('https://foo'))
        end
      ).to be_falsey
    end
    it 'does not affect redirectable? after an exception' do
      expect {
        open 'http://example.com', redirect_to_https: true,
          :proxy_http_basic_authentication => :oops, :proxy => :oops
      } .to raise_error(ArgumentError, /multiple proxy options/)
      expect(
        OpenURI.redirectable?(URI.parse('http://foo'),
                              URI.parse('https://foo'))
      ).to be_falsey
    end
  end                                                           # }}}1

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
    it 'redirects HTTP to HTTP to HTTPS' do
      expect(
        open('http://http-to-http-to-https.example.com',
          redirect_to_https: true).read
      ).to eq('HTTPS')
    end
    it 'redirects HTTP to HTTPS w/ block' do
      expect { |b|
        open('http://http-to-https.example.com', redirect_to_https: true, &b)
      } .to yield_control
    end
    it 'refuses to redirect HTTPS to HTTP w/ block' do
      expect { |b|
        open('https://https-to-http.example.com', redirect_to_https: true, &b)
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

  context 'w/ w_redirect_to_https' do                           # {{{1
    around(:each) do |example|
      OpenURI.w_redirect_to_https { example.run }
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
    # NB: brittle test
    it 'seems to work (could be false positive)' do
      allow(OpenURI).to receive(:open_uri_orig) do |*a,&b|
        sleep rand; OpenURI.open_uri_orig__ *a, &b
      end
      ts = []
      Thread.abort_on_exception = true
      begin
        100.times {
          ts << Thread.new {
            expect(
              open('http://http-to-http.example.com').read
            ).to eq('HTTP')
          }
          ts << Thread.new {
            expect(
              open('http://http-to-http.example.com',
                redirect_to_https: true).read
            ).to eq('HTTP')
          }

          ts << Thread.new {
            expect(
              open('https://https-to-https.example.com').read
            ).to eq('HTTPS')
          }
          ts << Thread.new {
            expect(
              open('https://https-to-https.example.com',
                redirect_to_https: true).read
            ).to eq('HTTPS')
          }

          ts << Thread.new {
            expect {
              open('http://http-to-https.example.com')
            } .to raise_error(RuntimeError, /redirection forbidden/)
          }
          ts << Thread.new {
            expect(
              open('http://http-to-https.example.com',
                redirect_to_https: true).read
            ).to eq('HTTPS')
          }
          ts << Thread.new {
            expect(
              OpenURI.w_redirect_to_https do
                open('http://http-to-https.example.com').read
              end
            ).to eq('HTTPS')
          }

          ts << Thread.new {
            expect {
              open('https://https-to-http.example.com')
            } .to raise_error(RuntimeError, /redirection forbidden/)
          }
          ts << Thread.new {
            expect {
              open('https://https-to-http.example.com', redirect_to_https: true)
            } .to raise_error(RuntimeError, /redirection forbidden/)
          }
        }
      ensure
        ts.each(&:join)
      end
    end
  end                                                           # }}}1

  context 'w/ (unaffected) defaults' do                         # {{{1
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

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
