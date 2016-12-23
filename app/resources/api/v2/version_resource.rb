class API::V2::VersionResource < JSONAPI::Resource
  model_name 'AddonVersion'

  attributes :version, :released, :ember_cli_version
  has_many :test_results
end
