# frozen_string_literal: true

class API::V2::TestResultResource < JSONAPI::Resource
  immutable
  attributes :succeeded, :status_message, :created_at, :semver_string, :canary, :output
  has_one :version, class_name: 'Version', relation_name: 'addon_version', foreign_key: 'addon_version_id'
  has_many :ember_version_compatibilities

  paginator :offset

  filter :addon_name, apply: ->(records, value, _options) {
    addon = Addon.where(name: value).first
    records.joins(:addon_version).where('addon_versions.addon_id = ?', addon.id)
  }

  filter :date, apply: ->(records, value, _options) {
    records.where('DATE(created_at) = ?', value)
  }

  filter :canary
end
