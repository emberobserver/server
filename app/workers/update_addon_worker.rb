# frozen_string_literal: true

class UpdateAddonWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  # List of package names that should be skipped. This is needed because some
  # packages get returned in the package list but then aren't available to fetch
  # as an individual package. (This is a bug in NPM.)
  SKIPPED_PACKAGES = %w[
    @choiceform/components-display
    @choiceform/components-feedback
    @choiceform/components-inputs
    @choiceform/components-navigation
    @choiceform/ui-foundation
    @phille/clickfunnels-marketplace-shared
    @phille/ember-base
    @unihorncorn/horn-styles
    @viviedu/ember-source
    ember-cli-fill-murray-michelegera
    ember-source-vivi
    ember-store-events
    trionyx
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
