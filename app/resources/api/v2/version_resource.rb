# frozen_string_literal: true

class API::V2::VersionResource < JSONAPI::Resource
  immutable
  model_name 'AddonVersion'

  attributes :version, :released, :ember_cli_version, :addon_name
  has_many :test_results
  has_one :addon
  has_one :addon_size, foreign_key_on: :related
end
