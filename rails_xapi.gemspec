require_relative "lib/rails-xapi/version"

Gem::Specification.new do |spec|
  spec.name = "rails-xapi"
  spec.version = RailsXapi::VERSION
  spec.authors = ["Hipjea"]
  spec.email = ["pierre.duverneix@gmail.com"]
  spec.homepage = "https://github.com/fondation-unit/rails-xapi"
  spec.summary = "Rails engine for generating xAPI statements."
  spec.description = "Rails engine for generating xAPI statements."
  spec.license = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata[
    "source_code_uri"
  ] = "https://github.com/fondation-unit/rails-xapi"
  spec.metadata[
    "changelog_uri"
  ] = "https://github.com/fondation-unit/rails-xapi/CHANGELOG.md"

  spec.files =
    Dir.chdir(File.expand_path(__dir__)) do
      Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
    end

  spec.add_dependency "rails", ">= 7.1.2"
  spec.add_development_dependency "rspec-rails"
end
