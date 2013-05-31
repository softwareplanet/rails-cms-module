# Encoding: UTF-8
$:.push File.expand_path("../lib", __FILE__)

# Version number: [major].[minor].[release].[build]
version = File.read(File.expand_path('../CMS_VERSION', __FILE__)).strip

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform      = Gem::Platform::RUBY
  s.name          = %q{softwareplanet-cms}
  s.version       = version
  s.description   = %q{A Ruby on Rails CMS that supports Rails 3.2. It's easy to extend and use.}
  s.summary       = %q{A Ruby on Rails CMS that supports Rails 3.2}
  s.email         = %q{no-reply@interlink-ua.com}
  s.homepage      = %q{http://www.interlink-ua.com}
  s.authors       = ['Inna Skorik', 'Yaroslava Velichko', 'Vitaly Pestov', 'Shevchuk Alexander']
  s.license       = %q{Open Core}
  s.require_paths = %w(lib)

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  # engine dependencies:
  s.add_dependency "rails"
  s.add_dependency "haml"
  s.add_dependency "minitest"
  #s.add_dependency "jquery-rails", "~> 3.0.0"
  s.add_dependency "aloha-rails"
  s.add_dependency "bootstrap-sass"
  s.add_dependency "codemirror-rails"
  s.add_dependency "imagesize"
  s.add_dependency "redcarpet"
  s.add_dependency "nokogiri"
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
