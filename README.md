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

## Usage

Create a service class or controller method within your main application that handles data preparation and invokes `XapiMiddleware::StatementCreator`:

```ruby
# frozen_string_literal: true

class XapiStatementCreator
  extend UserHelper

  def self.create_statement(request:, user:, data:)
    data = data.merge(actor: {objectType: "Agent"}) if data[:actor].blank?

    # We can set the actor's data to be able to omit it in the statements declarations.
    # This is an example. Adapt depending on your needs:
    data = data.merge(
      actor: data[:actor].merge(
        account: {
          homePage: "#{data[:base_url] || request.base_url}/users/#{user&.id}",
          name: user_fullname(user)
        }
      )
    )

    statement_creator = XapiMiddleware::StatementCreator.new(data, user)
    statement_creator.call_async
  end
end
```

You can then use the class within your controllers, for e.g.:

```ruby
XapiStatementCreator.create_statement(request: request, user: current_user, data: {
  verb: {
    id: "https://brindlewaye.com/xAPITerms/verbs/loggedin/"
  },
  object: {
    id: new_user_session_url,
    definition: {
      name: "log in",
      description: {
        "en-US" => "User signed in"
      },
      type: "sign-in"
    }
  }
})
```


## Test

```bash
bundle exec rails db:schema:load RAILS_ENV=test
rspec spec/
```


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
