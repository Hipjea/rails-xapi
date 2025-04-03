# Rails xAPI

xAPI statements creation plugin.

[![Actions Status](https://github.com/Hipjea/rails-xapi/actions/workflows/ci.yml/badge.svg)](https://github.com/Hipjea/rails-xapi/actions/workflows/ci.yml/)

> [!IMPORTANT]
> This is an ongoing development. The documentation will be provided as it becomes available.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "rails-xapi", git: "https://github.com/Hipjea/rails-xapi"
```

And then execute:

```bash
$ bundle
```

Create the migration files:

```bash
$ bin/rails rails_xapi:install:migrations
```

Mount the engine in `config/routes.rb`:

```ruby
mount RailsXapi::Engine, at: "rails-xapi"
```

## Usage

### Statement creation

Create a service class or controller method within your main application that handles data preparation and invokes `RailsXapi::StatementCreator`:

```ruby
class XapiStatementCreator
  def self.create_statement(data:, request: nil, user: nil, async: false)
    if request.present? && user.present?
      user_name = "#{user.firstname} #{user.lastname}"
      actor = {
        objectType: "Agent",
        name: user_name,
        mbox: "mailto:#{user.email}",
        account: {
          homePage: "#{data[:base_url] || request.base_url}/users/#{user&.id}",
          name: user_name
        }
      }
    end

    statement_creator = RailsXapi::StatementCreator.new(data, actor)
    return statement_creator.call(async: true) if async

    statement_creator.call
  end
end
```

You can then use the class within your controllers, for e.g.:

```ruby
XapiStatementCreator.create_statement(request: request, user: current_user, data: {
  # We can omit the actor struct if we pass the current_user to create_statement.
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

### Data query

```ruby
def logs_per_month(year = Date.current.year, month = Date.current.month)
  RailsXapi::QueryActor.user_statements_per_month({mbox: "mailto:#{email}"}, year, month)
end
```

## Test

```bash
bundle exec rails db:schema:load RAILS_ENV=test
bundle exec rspec spec/
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
