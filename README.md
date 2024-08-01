# xAPI Middleware

xAPI statements creation plugin.

> [!IMPORTANT]
> This is an ongoing development. The documentation will be provided as it becomes available.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "xapi_middleware", git: "https://github.com/fondation-unit/xapi_middleware"
```

And then execute:

```bash
$ bundle
```

Create the migration files:

```bash
$ bin/rails xapi_middleware:install:migrations
```

Mount the engine in `config/routes.rb`:

```ruby
mount XapiMiddleware::Engine, at: "xapi_middleware"
```

## Test

```bash
bundle exec rails db:schema:load RAILS_ENV=test
rspec spec/
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
