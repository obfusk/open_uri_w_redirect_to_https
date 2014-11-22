require File.expand_path('../lib/open_uri_w_redirect_to_https/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'open_uri_w_redirect_to_https'
  s.homepage    = 'https://github.com/obfusk/open_uri_w_redirect_to_https'
  s.summary     = 'open-uri HTTP to HTTPS redirect support patch'

  s.description = <<-END.gsub(/^ {4}/, '')
    open-uri HTTP to HTTPS redirect support patch
  END

  s.version     = OpenURIWithRedirectToHttps::VERSION
  s.date        = OpenURIWithRedirectToHttps::DATE

  s.authors     = [ 'Felix C. Stegerman' ]
  s.email       = %w{ flx@obfusk.net }

  s.licenses    = %w{ MIT }

  s.files       = %w{ .yardopts LICENSE README.md Rakefile } \
                + %w{ open_uri_w_redirect_to_https.gemspec } \
                + Dir['lib/**/*.rb']

  s.add_development_dependency 'fakeweb'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov', '~> 0.9.0'  # TODO
  s.add_development_dependency 'yard'

  s.required_ruby_version = '>= 1.9.1'
end
