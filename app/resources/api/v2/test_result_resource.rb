class API::V2::TestResultResource < JSONAPI::Resource
  attributes :succeeded, :status_message, :created_at, :semver_string, :canary
  has_one :version, class_name: 'Version', relation_name: 'addon_version'
  has_many :ember_version_compatibilities

  paginator :offset

  filter :addon_name, apply: ->(records, value, _options) {
    addon = Addon.where(name: value).first
    records.joins(:addon_version).where('addon_versions.addon_id = ?', addon.id)
  }

  filter :canary
end
