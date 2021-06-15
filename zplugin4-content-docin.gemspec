$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "zplugin/content/docin/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "zplugin4-content-docin"
  s.version     = Zplugin::Content::Docin::VERSION
  s.authors     = ["SiteBridge Inc."]
  s.email       = ["info@sitebridge.co.jp"]
  s.homepage    = "https://github.com/joruri/zplugin4-content-docin"
  s.summary     = "Import csv data into gp_article contents"
  s.description = "Import csv data into gp_article contents"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails"
  s.add_dependency "erubis"

  s.add_development_dependency "pg"
end
