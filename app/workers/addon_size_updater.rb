# frozen_string_literal: true

class AddonSizeUpdater < ApplicationJob

  def perform(addon_version_id, asset_sizes)
    addon_version = AddonVersion.find(addon_version_id)
    update_addon_size(addon_version, asset_sizes)
  end

  def update_addon_size(addon_version, asset_sizes)
    addon_version.addon_size = AddonSize.new(
      app_js_size: asset_sizes[:app_js],
      app_css_size: asset_sizes[:app_css],
      vendor_js_size: asset_sizes[:vendor_js],
      vendor_css_size: asset_sizes[:vendor_css]
    )
    addon_version.save!
  end

end
