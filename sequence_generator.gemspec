$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sequence_generator/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sequence_generator"
  s.version     = SequenceGenerator::VERSION
  s.authors     = ["vimox-shah"]
  s.email       = ["vimox@shipmnts.com"]
  s.homepage    = "https://github.com/vimox-shah/sequence_generator"
  s.summary     = "This is for Sequence generation"
  s.description = "You can create sequence for specific purpose with unique scope"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 5.0.0"

  s.add_dependency "pg"
  s.add_dependency "bundler", ">= 1.16"
  s.add_dependency "rake", ">= 10.0"
  s.add_dependency "activesupport", ">= 3.0"
  s.add_dependency "activerecord", ">= 3.0"
  s.add_dependency "active_model_serializers", '~> 0.10.3'
  s.add_dependency "rack-cors"
end
