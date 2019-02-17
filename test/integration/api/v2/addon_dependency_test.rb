# frozen_string_literal: true

require 'test_helper'

class API::V2::AddonDependencyTest < IntegrationTest
  ADDON_DEPENDENCY_ATTRIBUTES = %w[
    package
    dependency-type
  ].freeze

  ADDON_DEPENDENCY_RELATIONSHIPS = %w[
    dependent-version
  ].freeze

  test 'end user can fetch addon dependencies' do
    create_list :addon_version_dependency, 10, :is_addon

    get '/api/v2/addon-dependencies'

    parsed_response = json_response
    assert_equal 10, parsed_response['data'].length, 'All addon dependencies are returned'

    first_addon_dependency_response = parsed_response['data'][0]
    assert_equal first_addon_dependency_response['attributes'].keys, ADDON_DEPENDENCY_ATTRIBUTES, 'Addon dependency response includes expected fields'
    assert_equal first_addon_dependency_response['relationships'].keys, ADDON_DEPENDENCY_RELATIONSHIPS, 'Addon dependency response includes expected relationships'
  end

  test 'addon dependencies filtered by default to exclude non-addons' do
    addon_dependency = create :addon_version_dependency, :is_addon
    create :addon_version_dependency, :is_not_addon

    get '/api/v2/addon-dependencies'

    parsed_response = json_response
    assert_equal 1, parsed_response['data'].length, 'One addon dependency is returned'

    assert_equal addon_dependency.id.to_s, parsed_response['data'][0]['id']
  end

  test 'end user can fetch non-addon addon dependencies' do
    addon_dependency = create :addon_version_dependency, :is_addon
    non_addon_addon_dependency = create :addon_version_dependency, :is_not_addon

    get '/api/v2/addon-dependencies', params: { filter: { addons_only: false } }

    parsed_response = json_response
    assert_equal 2, parsed_response['data'].length, 'Both addon dependencies are returned'

    assert parsed_response['data'].find do |d|
      d['id'] == addon_dependency.id.to_s
    end
    assert parsed_response['data'].find do |d|
      d['id'] == non_addon_addon_dependency.id.to_s
    end
  end

  test 'end user can fetch individual addon dependency' do
    dependency = create :addon_version_dependency, :is_addon

    get "/api/v2/addon-dependencies/#{dependency.id}"

    assert_response 200
    assert_equal dependency.id.to_s, json_response['data']['id']
  end
end
