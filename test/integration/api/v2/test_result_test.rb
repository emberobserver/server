# frozen_string_literal: true

require 'test_helper'

class API::V2::ReviewTest < IntegrationTest
  TEST_RESULT_ATTRIBUTES = %w[
    ember-try-results
    succeeded
    status-message
    created-at
    semver-string
    canary
    output
    output-format
  ].freeze

  TEST_RESULT_RELATIONSHIPS = %w[
    version
    ember-version-compatibilities
  ].freeze

  test 'end user can fetch test results' do
    addon = create :addon
    addon_version = create :addon_version, addon: addon

    create :test_result, addon_version: addon_version, canary: false
    create :test_result, addon_version: addon_version, canary: true, created_at: '2018-01-18T05:00:00Z'
    create :test_result, addon_version: addon_version, canary: true, created_at: '2018-01-01T05:00:00Z'

    get '/api/v2/test-results', params: {
      filter: {
        canary: true,
        date: '2018-01-18'
      },
      include: 'ember-version-compatibilities,version,version.addon'
    }

    assert_response 200
    assert_equal 1, json_response['data'].length, 'One test result returned'
    test_result_response = json_response['data'][0]
    assert_equal test_result_response['attributes'].keys, TEST_RESULT_ATTRIBUTES, 'test result response includes expected fields'
    assert_equal test_result_response['relationships'].keys, TEST_RESULT_RELATIONSHIPS, 'test result response includes expected relationships'
  end
end
