# frozen_string_literal: true

class API::V2::AddonSizeResource < JSONAPI::Resource
  immutable
  # rubocop:disable Layout/AlignParameters
  attributes :app_js_size,
             :app_css_size,
             :vendor_js_size,
             :vendor_css_size,
             :other_js_size,
             :other_css_size
  # rubocop:enable Layout/AlignParameters

  has_one :version, class_name: 'Version', relation_name: 'addon_version', foreign_key: 'addon_version_id'
end
