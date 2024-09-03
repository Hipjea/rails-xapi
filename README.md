# Rails xAPI

xAPI statements creation plugin.

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

    statement_creator = RailsXapi::StatementCreator.new(data, user)
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


### Data query

```ruby
def logs_per_month(year = Date.current.year, month = Date.current.month)
  RailsXapi::QueryActor.user_statements_per_month({mbox: "mailto:#{email}"}, year, month)
end
```


## Test

```bash
bundle exec rails db:schema:load RAILS_ENV=test
rspec spec/
```


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
