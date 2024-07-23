# frozen_string_literal: true

# Statements are the evidence for any sort of experience or event which is to be tracked in xAPI.
# See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#20-statements
class XapiMiddleware::Statement < ApplicationRecord
  belongs_to :actor, class_name: "XapiMiddleware::Actor"
  belongs_to :verb, class_name: "XapiMiddleware::Verb"
  belongs_to :object, class_name: "XapiMiddleware::Object"
  has_one :result, class_name: "XapiMiddleware::Result", dependent: :destroy
  has_one :context, class_name: "XapiMiddleware::Context", dependent: :destroy

  validate :actor_valid
  validate :verb_valid
  validate :object_valid

  private

  def actor_valid
    errors.add(:actor, "is invalid") if actor && !actor.valid?
  end

  def verb_valid
    errors.add(:verb, "is invalid") if verb && !verb.valid?
  end

  def object_valid
    errors.add(:object, "is invalid") if object && !object.valid?
  end
end

# == Schema Information
#
# Table name: xapi_middleware_statements
#
#  id         :integer          not null, primary key
#  timestamp  :datetime
#  created_at :datetime         not null
#  actor_id   :string           not null
#  object_id  :string           not null
#  verb_id    :string           not null
#
# Indexes
#
#  index_xapi_middleware_statements_on_actor_id   (actor_id)
#  index_xapi_middleware_statements_on_object_id  (object_id)
#  index_xapi_middleware_statements_on_verb_id    (verb_id)
#
