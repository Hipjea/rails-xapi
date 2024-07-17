# frozen_string_literal: true

# Statements are the evidence for any sort of experience or event which is to be tracked in xAPI.
# See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#20-statements
class XapiMiddleware::Statement < ApplicationRecord
  belongs_to :actor, class_name: "XapiMiddleware::Actor"
  belongs_to :verb, class_name: "XapiMiddleware::Verb"
  belongs_to :object, class_name: "XapiMiddleware::Object"
end

# == Schema Information
#
# Table name: xapi_middleware_statements
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  actor_id   :integer
#  object_id  :integer
#  verb_id    :integer
#
# Indexes
#
#  index_xapi_middleware_statements_on_actor_id   (actor_id)
#  index_xapi_middleware_statements_on_object_id  (object_id)
#  index_xapi_middleware_statements_on_verb_id    (verb_id)
#
# Foreign Keys
#
#  actor_id   (actor_id => actors.id)
#  object_id  (object_id => objects.id)
#  verb_id    (verb_id => verbs.id)
#
