# frozen_string_literal: true

require 'test_helper'

class API::V2::ScoreCalculationTest < IntegrationTest
  test 'can fetch latest score calculation for an addon' do
    addon = create :addon
    addon_version = create :addon_version, addon: addon

    other_addon = create :addon
    other_addon_version = create :addon_version, addon: other_addon

    create :score_calculation, addon: addon, addon_version: addon_version, info: { score: 1 }
    create :score_calculation, addon: addon, addon_version: addon_version, info: { score: 3 }
    create :score_calculation, addon: other_addon, addon_version: other_addon_version, info: { score: 5 }

    get '/api/v2/score-calculations', params: { filter: { addon_id: addon.id, latest: true } }

    assert_response :success
    parsed_response = json_response
    assert_equal 1, parsed_response['data'].length, 'Only one score calc returned'
    assert_equal 3, parsed_response['data'][0]['attributes']['info']['score']
  end

  test 'camelizes info attribute, nested' do
    addon = create :addon
    addon_version = create :addon_version, addon: addon

    create :score_calculation, addon: addon, addon_version: addon_version, info: {
      score: 3, addon_name: 'ember-try', checks: [
        { max_weight: 5, foo: 'baz' },
        { weighted_thing: 4, foo_bar: 'bar' }
      ]
    }

    get '/api/v2/score-calculations', params: { filter: { addon_id: addon.id, latest: true } }

    assert_response :success
    parsed_response = json_response
    info_attribute = parsed_response['data'][0]['attributes']['info']
    assert_equal 'ember-try', info_attribute['addonName']
    assert_equal 5, info_attribute['checks'][0]['maxWeight']
    assert_equal 'baz', info_attribute['checks'][0]['foo']
    assert_equal 'bar', info_attribute['checks'][1]['fooBar']
    assert_equal 4, info_attribute['checks'][1]['weightedThing']
  end
end
