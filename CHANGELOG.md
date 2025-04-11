# Changelog

## 0.1.2

### Breaking Changes:

- Removed `call_async` method from `RailsXapi::StatementCreator`, in favor of merging it into the `call` method.
- Query service changes (see [query_spec.rb](./spec/services/rails_xapi/query_spec.rb)):
  - Renaming the class for `RailsXapi::Query`
  - The new class references all query methods and can be called as follows: `RailsXapi::Query.call(query: :verb_ids)`
