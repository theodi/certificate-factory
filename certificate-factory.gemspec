$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "certificate-factory/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "certificate-factory"
  s.version     = CertificateFactory::VERSION
  s.authors     = ["Stuart Harrison"]
  s.email       = ["tech@theodi.org"]
  s.homepage    = "http://theodi.org"
  s.summary     = "Automagically generate Open Data Certificates from a CKAN Dataset or Data.gov.uk atom feed."
  s.description = "Automagically generate Open Data Certificates from a CKAN Dataset or Data.gov.uk atom feed."
  s.license     = "MIT"

  s.files = `git ls-files`.split($\)
  s.require_paths = ["lib", "app"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "httparty"
  s.add_dependency "dotenv"
  s.add_dependency "rake"

  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "simplecov-rcov"
  s.add_development_dependency "coveralls"
  s.add_development_dependency "pry"
  s.add_development_dependency "webmock"
  s.add_development_dependency "vcr"
  s.add_development_dependency "pry-remote"
end
