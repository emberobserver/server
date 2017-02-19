class API::V2::VersionResource < JSONAPI::Resource
  immutable
  model_name 'AddonVersion'

  attributes :version, :released, :ember_cli_version
  has_many :test_results
  has_one :addon
end
