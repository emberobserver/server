# frozen_string_literal: true

class AddonScoreWorker
  include Sidekiq::Worker

  def perform(addon_id)
    addon = Addon.find(addon_id)
    update_score(addon)
    update_badge(addon)
  end

  private

  def update_score(addon)
    AddonScoreUpdater.new(addon).update
  end

  def update_badge(addon)
    BadgeGenerator.new(addon).generate
  end
end
