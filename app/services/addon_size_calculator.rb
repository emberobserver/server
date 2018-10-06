# frozen_string_literal: true

class AddonSizeCalculator
  def self.calculate_addon_sizes(addons)
    ember_new_output = EmberNewOutput.install
    addons.each do |addon|
      addon_version = addon.newest_version
      next if addon_version.has_size_data?

      begin
        diff = ember_new_output.install_addon_and_measure(addon_version)
        AddonSizeUpdater.perform_async(addon_version.id, diff.to_h) if diff
      rescue StandardError => e
        Rails.logger.error("Failed to measure addon #{addon_version.addon_name}: #{e}")
      end
    end
    ember_new_output.cleanup
  end
end
