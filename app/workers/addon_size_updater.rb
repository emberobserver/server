# frozen_string_literal: true
class AddonSizeUpdater < ApplicationJob

  def self.setup
    AddonInstaller.install_ember_new
  end

  def self.teardown
    AddonInstaller.cleanup
  end

  def perform(addon_id)
    # TODO: this is pointless as a job since they can't be run async
    # unless the entire ember-cli-new directory is cloned
    addon = Addon.find(addon_id)

    if Dir.exist? AddonInstaller.install_dir
      generate_asset_size_data(addon.newest_version)
    else
      raise("ember-cli-new is not installed in the expected location. Please run #{self.class.name}.setup")
    end
  end

  def generate_asset_size_data(addon_version)
    install_and_measure_assets(addon_version)
    update_addon_size(addon_version, generate_diff)
  rescue => e
    Rails.logger.error("Unable to update asset sizes for #{addon_version.addon_name}: #{e.message}")
  end

  def install_and_measure_assets(addon_version)
    AddonInstaller.install_addon(addon_version)
  end

  def update_addon_size(addon_version, diff)
    addon_version.addon_size = AddonSize.new(
      app_js_size: diff.app_js, 
      app_css_size: diff.app_css,
      vendor_js_size: diff.vendor_js,
      vendor_css_size: diff.vendor_css
    )
    addon_version.save!
  end

  def generate_diff 
    base_size_data = parse_json_file(AddonInstaller.base_size_filename)
    base_plus_addon_size_data = parse_json_file(AddonInstaller.addon_size_filename)
    AddonSizeDiff.new(base_size_data, base_plus_addon_size_data)
  end

  def parse_json_file(file_name)
    file_contents = File.read(file_name)
    file_parser = AssetSizeParser.new(file_contents)
    file_parser.asset_size_json
  end
end
