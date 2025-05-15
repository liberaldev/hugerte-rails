require File.expand_path('../lib/hugerte/rails/version', __FILE__)

Gem::Specification.new do |s|
  s.name = "hugerte-rails"
  s.version = HugeRTE::Rails::VERSION
  s.summary = "Rails asset pipeline integration for HugeRTE."
  s.description = "Seamlessly integrates HugeRTE into the Rails asset pipeline introduced in Rails 3.1."
  s.files = Dir["README.md", "LICENSE", "Rakefile", "app/**/*", "lib/**/*", "vendor/assets/**/*"]
  s.authors = ["Liberal Dev", "Sam Pohlenz"]
  s.email = ""
  s.homepage = "https://github.com/liberaldev/hugerte-rails"
  s.license = "MIT"
  
  s.add_dependency "railties",  ">= 3.1.1"
end
