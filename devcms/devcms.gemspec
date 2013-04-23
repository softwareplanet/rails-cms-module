# Encoding: UTF-8
$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "devcms/version"
version = Devcms::VERSION.to_s

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform      = Gem::Platform::RUBY
  s.name          = %q{devcms}
  s.version       = version
  s.description   = %q{A Ruby on Rails CMS that supports Rails 3.2. It's easy to extend and use.}
  s.summary       = %q{A Ruby on Rails CMS that supports Rails 3.2}
  s.email         = %q{no-reply@interlink-ua.com}
  s.homepage      = %q{http://www2.interlink-ua.com}
  s.authors       = ['Inna Skorik', 'Yaroslava Velichko', 'Vitaly Pestov', 'Shevchuk Alexander']
  s.license       = %q{Open Core}
  s.require_paths = %w(lib)

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  # engine dependencies:
  s.add_dependency "rails"
  s.add_dependency "haml"
  s.add_dependency "jquery-rails"
  s.add_dependency "aloha-rails"
  s.add_dependency "bootstrap-sass"
  s.add_dependency "codemirror-rails"
  s.add_dependency "imagesize"
  # assets dependencies:
  s.add_dependency 'sass-rails'
  s.add_dependency 'coffee-rails'
  s.add_dependency 'uglifier'
  # rspec dependencies:
  s.add_development_dependency "aloha-rails"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "shoulda-matchers"
  s.add_development_dependency "database_cleaner"
end
