source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in xapi_middleware.gemspec.
gemspec

gem "puma"

gem "sqlite3"

gem "sprockets-rails"

# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"

group :development do
  gem "annotate"
  gem "brakeman"
  gem "guard"
  gem "guard-brakeman"
  gem "guard-reek"
  gem "guard-rubocop"
  gem "rubocop"
  gem "rubocop-rails"
  gem "rubocop-rspec"
  gem "standard"
end

group :development, :test do
  gem "rspec-rails"
  gem "guard-rspec", require: false
end
