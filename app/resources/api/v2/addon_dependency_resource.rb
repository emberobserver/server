# frozen_string_literal: true

class API::V2::AddonDependencyResource < JSONAPI::Resource
  immutable
  model_name 'AddonVersionDependency'

  attributes :package, :dependency_type

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
end
