# frozen_string_literal: true

class UpdateAddonWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 5

  def perform(addon_name)
    data = PackageFetcher.run(addon_name)
    NpmAddonDataUpdater.new(data).update
  end
end
