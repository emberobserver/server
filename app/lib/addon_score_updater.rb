# frozen_string_literal: true

class AddonScoreUpdater
  attr_reader :addon, :score

  def initialize(addon)
    @addon = addon
  end

  def update(score_info = calculate_score)
    return unless addon.reviewed?
    score = score_info[:score]
    save_score_to_addon(score)
    save_score_to_latest_version(score)
    save_score_calc(score_info)
  end

  def calculate_score
    AddonScore::Calculator.calculate_score(addon)
  end

  def save_score_calc(score_info)
    ScoreCalculation.find_or_create_by!(addon_id: addon.id, addon_version_id: addon.latest_addon_version_id, info: score_info)
  end

  private

  def save_score_to_addon(score)
    addon.score = score
    addon.save
  end

  def save_score_to_latest_version(score)
    latest_version = addon.latest_addon_version
    return unless latest_version

    latest_version.score = score
    latest_version.save
  end
end
