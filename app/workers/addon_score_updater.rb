# frozen_string_literal: true

class AddonScoreUpdater
  include Sidekiq::Worker

  def perform(addon_id)
    addon = Addon.find(addon_id)
    update_score(addon)
    update_badge(addon)
  end

  private

  def update_score(addon)
    score_info = AddonScore::Calculator.calculate_score(addon)
    score = score_info[:score]
    addon.score = score

    # Save score info to jsonb place

    latest_version = addon.latest_addon_version
    if latest_version
      latest_version.score = addon.score
      latest_version.save
    end
    addon.save
  end

  def update_badge(addon)
    BadgeGenerator.new(addon).generate
  end
end
