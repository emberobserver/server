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
    addon.score = AddonScoreCalculator.calculate_score(addon)
    latest_version = addon.latest_addon_version
    if latest_version
      latest_version.score = addon.score
      latest_version.save
    end
    addon.save
  end

  def update_badge(addon)
    score = 'na'
    if addon.is_wip
      score = 'wip'
    else
      score = addon.score || 'na'
    end

    addon_badge_dir = ENV['ADDON_BADGE_DIR'] || Rails.root.join('public/badges')
    badge_image_path = Rails.root.join("app/assets/images/badges/#{score}.svg")
    badge_image_name = File.join(addon_badge_dir, "#{safe_name addon.name}.svg")
    FileUtils.copy badge_image_path, badge_image_name
    File.chmod 0644, badge_image_name
  end

  def safe_name(name)
    name.gsub(/[^A-Za-z0-9]/, '-')
  end
end
