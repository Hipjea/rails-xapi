source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in rails-xapi.gemspec.
gemspec

gem "puma"

gem "sqlite3", "~> 1.3", ">= 1.3.11"

gem "sprockets-rails"

# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"

group :development do
  gem "brakeman"
  gem "guard"
  gem "guard-brakeman"
  gem "guard-reek"
  gem "guard-rubocop"
  gem "rubocop"
  gem "rubocop-rails"
  gem "rubocop-rspec"
  gem "standard", ">= 1.35.1"
end

group :development, :test do
  gem "rspec-rails"
  gem "guard-rspec", require: false
end

group :test do
  gem "simplecov", require: false
end

gem "annotate"
