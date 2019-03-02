# frozen_string_literal: true

class BadgeGenerator
  def initialize(addon)
    @addon = addon
  end

  def generate
    FileUtils.copy template_badge_path, addon_badge_path
    File.chmod 0o644, addon_badge_path
  end

  def template_badge_path
    Rails.root.join("app/assets/images/badges/#{badge_score}.svg")
  end

  def addon_badge_path
    File.join(badge_directory, "#{safe_name addon.name}.svg")
  end

  private

  attr_reader :addon

  def badge_score
    if addon.is_wip
      'wip'
    else
      addon.score_to_fixed || 'na'
    end
  end

  def badge_directory
    ENV['ADDON_BADGE_DIR'] || Rails.root.join('public/badges')
  end

  def safe_name(name)
    name.gsub(/[^A-Za-z0-9]/, '-')
  end
end
