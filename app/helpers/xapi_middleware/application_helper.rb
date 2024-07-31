module XapiMiddleware
  module ApplicationHelper
    def parse_hash_string(hash_string)
      require "json"

      # Replace Ruby hash syntax with JSON syntax
      json_string = hash_string.gsub("=>", ":").gsub('\"', '\"')
      # Fix any possible issues with escaping double quotes
      json_string = json_string.gsub(':\\\\\"', '\"')

      JSON.parse(json_string)
    end
  end
end
