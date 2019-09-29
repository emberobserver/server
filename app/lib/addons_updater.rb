# frozen_string_literal: true

class AddonsUpdater
  def self.run
    matching_npm_packages = PackageListFetcher.run

    if matching_npm_packages.length < 6000
      raise "Did not find at least 6000 matching packages, found: #{matching_npm_packages.length}"
    end

    addons_to_update = addons_in_need_of_update(matching_npm_packages)
    addons_to_update.each do |a|
      UpdateAddonWorker.perform_async(a[:name])
    end

    log_updates(addons_to_update)
    mark_completion
  end

  def self.addons_in_need_of_update(matching_npm_packages, hour = Time.current.hour)
    addons_needing_updating = []
    matching_npm_packages.each do |a|
      addon_data = a['package']
      addon_name = addon_data['name']
      addon = Addon.find_by(name: addon_name)

      unless addon
        addons_needing_updating << { name: addon_name, reason: 'New addon' }
        next
      end

      addon_scheduled_to_be_updated = scheduled_to_be_updated?(addon.id, hour)
      addon_updated_since_last_fetch = Time.zone.parse(addon_data['date']) > addon.latest_version_date
      if addon_updated_since_last_fetch
        addons_needing_updating << { name: addon_name, reason: 'Out of date' }
      elsif addon_scheduled_to_be_updated
        addons_needing_updating << { name: addon_name, reason: 'Scheduled' }
      end
    end
    addons_needing_updating
  end

  def self.scheduled_to_be_updated?(addon_id, hour)
    addon_id % 12 == hour % 12
  end

  def self.log_updates(updating_addons)
    breakdown = {}
    updating_addons.group_by { |a| a[:reason] }.each_pair do |reason, addons|
      breakdown[reason] = addons.length
    end
    Rails.logger.info 'Addons updater run', updating: updating_addons.length, breakdown: breakdown
  end

  def self.mark_completion
    Snitcher.snitch(ENV['FETCH_SNITCH_ID']) if Rails.env.production?
  end
end
