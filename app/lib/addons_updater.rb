# frozen_string_literal: true

class AddonsUpdater
  def self.run
    matching_npm_packages = PackageListFetcher.run

    if matching_npm_packages.length < 4500
      raise RuntimeError("Did not find at least 4500 matching packages, found: #{matching_npm_packages.length}")
    end

    addons_to_update = addons_in_need_of_update(matching_npm_packages)
    addons_to_update.each do |addon_name|
      UpdateAddonWorker.perform_async(addon_name)
    end
    addons_to_update
  end

  def self.addons_in_need_of_update(matching_npm_packages)
    addons_needing_updating = []
    matching_npm_packages.each do |a|
      addon_data = a['package']
      addon_name = addon_data['name']
      addon = Addon.find_by(name: addon_name)

      unless addon
        addons_needing_updating << addon_name
        next
      end

      if Time.zone.parse(addon_data['date']) > addon.latest_version_date
        addons_needing_updating << addon_name
      end
    end
    addons_needing_updating
  end
end
