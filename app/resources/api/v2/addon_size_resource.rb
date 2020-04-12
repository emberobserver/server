# frozen_string_literal: true

class API::V2::AddonSizeResource < JSONAPI::Resource
  immutable
  attributes :app_js_size, :app_css_size,
    :vendor_js_size, :vendor_css_size,
    :other_js_size, :other_css_size,
    :app_js_gzip_size, :app_css_gzip_size,
    :vendor_js_gzip_size, :vendor_css_gzip_size,
    :other_js_gzip_size, :other_css_gzip_size,
    :other_assets
end
