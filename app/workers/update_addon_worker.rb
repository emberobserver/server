# frozen_string_literal: true

class UpdateAddonWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  # List of package names that should be skipped and not updated.
  # When an addon is removed from NPM but we are still trying to update it,
  # it is better to set Addon#removed_from_npm to `true` (which will also skip
  # updates for that package). This list should be used for package names that
  # need to be skipped for any other reason.
  SKIPPED_PACKAGES = %w[
  ].freeze

  def perform(addon_name)
    return if skip_addon?(addon_name)

    data = PackageFetcher.run(addon_name)
    addon = NpmAddonDataUpdater.new(data).update
    AddonScoreWorker.perform_async(addon.id)
  end

  private

  def skip_addon?(name)
    return true if SKIPPED_PACKAGES.include?(name)

    addon = Addon.find_by(name: name)
    return false if addon.nil?

    return addon.removed_from_npm
  end
end
