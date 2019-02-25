# frozen_string_literal: true

require 'test_helper'

class API::V2::EmberVersionTest < IntegrationTest
  test 'can fetch Ember versions' do
    create_list :ember_version, 12

    get '/api/v2/ember-versions'

    assert_response :success
    parsed_response = json_response
    assert_equal 12, parsed_response['data'].length, 'All Ember versions are returned'
  end

  test 'can get only non-beta versions with a filter' do
    create_list :ember_version, 5
    create_list :ember_version, 6, :beta

    get '/api/v2/ember-versions?filter[release]=true'

    assert_response :success
    parsed_response = json_response
    assert_equal 5, parsed_response['data'].length, 'beta versions are excluded when filter is provided'
  end

  test 'can get only x.y.0 versions with a filter' do
    create_list :ember_version, 2, :major
    create_list :ember_version, 3, :minor
    create_list :ember_version, 4, :beta
    create_list :ember_version, 10, :point_release

    get '/api/v2/ember-versions?filter[major_and_minor]=true'

    assert_response :success

    parsed_response = json_response
    assert_equal 5, parsed_response['data'].length, 'betas and point releases are excluded'
  end
end
