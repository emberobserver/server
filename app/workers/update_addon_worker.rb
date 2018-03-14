# frozen_string_literal: true

class UpdateAddonWorker
  include Sidekiq::Worker

  def perform(addon_name)
    PackageFetcher.run(addon_name)
  end
end
