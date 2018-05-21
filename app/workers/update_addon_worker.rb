# frozen_string_literal: true

class UpdateAddonWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform(addon_name)
    data = PackageFetcher.run(addon_name)
    addon = NpmAddonDataUpdater.new(data).update
    AddonScoreUpdater.perform_async(addon.id)
  end
end
