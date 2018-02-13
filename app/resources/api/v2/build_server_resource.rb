# frozen_string_literal: true

class API::V2::BuildServerResource < JSONAPI::Resource
  attributes :name, :token, :created_at
end
