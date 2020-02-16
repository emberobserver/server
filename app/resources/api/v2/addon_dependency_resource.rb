# frozen_string_literal: true

class API::V2::AddonDependencyResource < JSONAPI::Resource
  immutable
  model_name 'AddonVersionDependency'

  attributes :package, :dependency_type, :package_addon_id

  has_one :dependent_version, class_name: 'Version', relation_name: 'addon_version', foreign_key: 'addon_version_id'

  filter :visible_addons_only, apply: ->(records, value, _options) {
    addons_only = ActiveModel::Type::Boolean.new.cast(value[0])
    if addons_only
      records.joins(:package_addon).merge(Addon.not_hidden)
    else
      records
    end
  }, default: true

  filter :addon_version_id
  filter :dependency_type

  filter :package_addon_id, apply: ->(records, value, _options) {
    package_addon_id = value[0]
    latest_versions_sql = Addon.not_hidden.where('latest_addon_version_id is not null').select('latest_addon_version_id as id, name as addon_name').to_sql
    records.where(package_addon_id: package_addon_id)
           .joins("inner join (#{latest_versions_sql}) as latest_versions on latest_versions.id = addon_version_id")
  }
end
