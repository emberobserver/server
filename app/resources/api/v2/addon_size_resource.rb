# frozen_string_literal: true

class API::V2::AddonSizeResource < JSONAPI::Resource
  immutable
  attributes :app_js_size, :vendor_js_size, :other_js_size, :addon_version_id

  has_one :addon_version, class_name: 'Version'

  filter :addon_id, apply: ->(records, value, _options) {
    addon_ids = value[0]
    # TODO does this return multiple addon sizes if they exist for different addon versions?
    records.joins(addon_version: [:addon]).where('addons.id in (?)', addon_ids)
  }
end
