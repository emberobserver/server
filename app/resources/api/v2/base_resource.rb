
# frozen_string_literal: true

class API::V2::BaseResource < JSONAPI::Resource
  abstract

  REQUIRE_ADMIN = ->(values, context) {
    if values.include?('true') && context[:current_user].nil?
      raise Forbidden
    end
    values
  }
end
