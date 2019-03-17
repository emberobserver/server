# frozen_string_literal: true

require 'test_helper'

class ScoreHistoryTest < ActiveSupport::TestCase
  test 'data_by_model_version' do
    addon_b = create :addon
    addon_version_b = create :addon_version, addon: addon_b
    create :score_calculation, addon: addon_b, addon_version: addon_version_b, info: {
      score: 9, addon_name: 'ember-info', model_version: 1
    }
    create :score_calculation, addon: addon_b, addon_version: addon_version_b, info: {
      score: 9.2, addon_name: 'ember-info', model_version: 2
    }

    addon = create :addon
    addon_version = create :addon_version, addon: addon
    create :score_calculation, addon: addon, addon_version: addon_version, info: {
      score: 3, addon_name: 'ember-try', model_version: 1
    }
    create :score_calculation, addon: addon, addon_version: addon_version, info: {
      score: 2.9, addon_name: 'ember-try', model_version: 2
    }
    create :score_calculation, addon: addon, addon_version: addon_version, info: {
      score: 2.3, addon_name: 'ember-try', model_version: 2
    }

    data = ScoreHistory.data_by_model_version

    assert_equal({
      1 => [
        { name: 'ember-info', score: 9, model_version: 1 },
        { name: 'ember-try', score: 3, model_version: 1 }
      ],
      2 => [
        { name: 'ember-info', score: 9.2, model_version: 2 },
        { name: 'ember-try', score: 2.3, model_version: 2 }
      ]
    }, data)
  end

  test 'rows_by_model_version' do
    addon_b = create :addon
    addon_version_b = create :addon_version, addon: addon_b
    create :score_calculation, addon: addon_b, addon_version: addon_version_b, info: {
      score: 9, addon_name: 'ember-info', model_version: 1
    }
    create :score_calculation, addon: addon_b, addon_version: addon_version_b, info: {
      score: 9.2, addon_name: 'ember-info', model_version: 2
    }

    addon = create :addon
    addon_version = create :addon_version, addon: addon
    create :score_calculation, addon: addon, addon_version: addon_version, info: {
      score: 3, addon_name: 'ember-try', model_version: 1
    }
    create :score_calculation, addon: addon, addon_version: addon_version, info: {
      score: 2.9, addon_name: 'ember-try', model_version: 2
    }
    create :score_calculation, addon: addon, addon_version: addon_version, info: {
      score: 2.3, addon_name: 'ember-try', model_version: 2
    }

    addon_c = create :addon
    addon_version_c = create :addon_version, addon: addon_c
    create :score_calculation, addon: addon_c, addon_version: addon_version_c, info: {
      score: 7, addon_name: 'ember-newly-published-addon', model_version: 2
    }

    data = ScoreHistory.rows_by_model_version

    assert_equal([
                   ['Addon', 'Model 1', 'Model 2'],
                   ['ember-info', 9, 9.2],
                   ['ember-newly-published-addon', nil, 7],
                   ['ember-try', 3, 2.3]
                 ], data)
  end
end
