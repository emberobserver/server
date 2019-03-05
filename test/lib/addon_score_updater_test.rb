# frozen_string_literal: true

require 'test_helper'

class AddonScoreUpdaterTest < ActiveSupport::TestCase
  test '#update saves score' do
    version = create :addon_version
    addon = version.addon
    addon.latest_addon_version = version
    addon.save

    assert_nil addon.score
    assert_nil version.score
    assert_equal 0, ScoreCalculation.count

    create_updater(addon).update(
      score: 9
    )

    assert_equal 9, addon.score, 'Saves score to addon'
    assert_equal 9, version.score, 'Saves score to version'
    assert_equal 9, ScoreCalculation.last.info['score'], 'Saves score calculation'
  end

  test '#calculate_score' do
    version = create :addon_version
    addon = version.addon
    addon.latest_addon_version = version
    addon.save

    assert_equal 0, ScoreCalculation.count

    updater = create_updater(addon)

    assert_equal 0, ScoreCalculation.count
    updater.save_score_calc(score: 8)

    score_calc = ScoreCalculation.last
    assert_equal 8, score_calc.info['score']

    updater.save_score_calc(score: 8)

    assert_equal 1, ScoreCalculation.count, 'Additional update does not create new score calc entries'
  end

  private

  def create_updater(addon)
    AddonScoreUpdater.new(addon)
  end
end
