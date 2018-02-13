# frozen_string_literal: true

class API::V2::KeywordResource < JSONAPI::Resource
  immutable
  model_name 'NpmKeyword'

  attributes :keyword

  has_many :addons
end
