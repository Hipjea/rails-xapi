# frozen_string_literal: true

# The optional context activity.
# See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#246-context
class XapiMiddleware::ContextActivity < ApplicationRecord
  belongs_to :context, class_name: "XapiMiddleware::Context"
  belongs_to :object, class_name: "XapiMiddleware::Object"

  validates :activity_type, presence: true, inclusion: {in: ["parent", "grouping", "category", "other"]}

  def type=(value)
    # We store the `type` attribute into `activity_type` column to avoid
    # reserved key-words issues.
    self.activity_type = value
  end
end
