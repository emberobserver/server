# frozen_string_literal: true

class UpdateAddonWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  # List of package names that should be skipped. This is needed because some
  # packages get returned in the package list but then aren't available to fetch
  # as an individual package. (This is a bug in NPM.)
  SKIPPED_PACKAGES = %w[
    @choiceform/ui-foundation
    @unihorncorn/horn-styles
  ].freeze

  def perform(addon_name)
    return if SKIPPED_PACKAGES.include?(addon_name)

    data = PackageFetcher.run(addon_name)
    addon = NpmAddonDataUpdater.new(data).update
    AddonScoreWorker.perform_async(addon.id)
  end
end
