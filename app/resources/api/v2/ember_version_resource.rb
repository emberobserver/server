# frozen_string_literal: true

class API::V2::EmberVersionResource < JSONAPI::Resource
  immutable

  attributes :name, :released
end
