# Rails xAPI

xAPI statements creation plugin.

[![Actions Status](https://github.com/fondation-unit/rails-xapi/actions/workflows/ci.yml/badge.svg)](https://github.com/fondation-unit/rails-xapi/actions/workflows/ci.yml/)

> [!IMPORTANT]
> This is an ongoing development. The documentation will be provided as it becomes available.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "rails-xapi", git: "https://github.com/fondation-unit/rails-xapi"
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

Example usage of the `RailsXapi::StatementCreator` service:

```ruby
user_name = "#{user.firstname} #{user.lastname}"

data = {
  actor: {
    objectType: "Agent",
    name: user_name,
    mbox: "mailto:#{user.email}",
    account: {
      homePage: "http://example.com/some_user_homepage/#{user&.id}",
      name: user_name
    }
  },
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
}

RailsXapi::StatementCreator.create(data)
```

### Data query

Ready-to-use queries are available in the [app/services/rails_xapi/query.rb](app/services/rails_xapi/query.rb) class.

| Query symbol                       | Description                                               |
| ---------------------------------- | --------------------------------------------------------- |
| `:statement`                       | Retrieve a single statement by its ID                     |
| `:statements_by_object_and_actors` | Get statements by object IDand actor emails               |
| `:verb_ids`                        | Get list of unique verb IDs                               |
| `:verb_displays`                   | Get list of unique verb display values                    |
| `:verbs`                           | Get hash of unique verbs with ID and display values       |
| `:actor_by_email`                  | Find statements by actor's email                          |
| `:actor_by_mbox`                   | Find statements by actor's mbox                           |
| `:actor_by_account_homepage`       | Find statements by actor's account homepage               |
| `:actor_by_openid`                 | Find statements by actor's openID                         |
| `:actor_by_mbox_sha1sum`           | Find statements by actor's mbox SHA1 sum                  |
| `:user_statements_per_month`       | Retrieve actor's statements for a specific month/year     |
| `:per_month`                       | Group given records by creation date for a specific month |
| `:month_graph_data`                | Create date/count array of data for a month               |

Example of usage:

```ruby
def logs_per_month(year = Date.current.year, month = Date.current.month)
  RailsXapi::Query.call(
    query: :user_statements_per_month,
    args: [{mbox: "mailto:#{email}"}, year, month]
  )
end
```

## Test

```bash
bundle exec rails db:schema:load RAILS_ENV=test
bundle exec rspec spec/
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
