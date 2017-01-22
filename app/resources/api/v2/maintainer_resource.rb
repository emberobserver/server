class API::V2::MaintainerResource < JSONAPI::Resource
  immutable
  model_name 'NpmMaintainer'

  attributes :name, :gravatar
  has_many :addons
end
