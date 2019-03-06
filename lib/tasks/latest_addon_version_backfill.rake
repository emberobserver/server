# frozen_string_literal: true

namespace :data do
  task backfill_latest_addon_version: :environment do
    addons = Addon.where('latest_addon_version_id is NULL')
    addons.each do |a|
      unless a.addon_versions.empty?
        a.latest_addon_version_id = a.addon_versions.last.id
        a.save
      end
    end
  end
end
