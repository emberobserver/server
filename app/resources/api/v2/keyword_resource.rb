class API::V2::KeywordResource < JSONAPI::Resource
  model_name 'NpmKeyword'

  attributes :keyword

  has_many :addons
end
