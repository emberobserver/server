# frozen_string_literal: true

require 'test_helper'

class API::V2::AddonDependencyTest < IntegrationTest
  ADDON_DEPENDENCY_ATTRIBUTES = %w[
    package
    dependency-type
  ].freeze

  ADDON_DEPENDENCY_RELATIONSHIPS = %w[
    dependent-version
    package-addon
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

  test 'end user can fetch the latest dependents of a given addon' do
    addon_to_look_up = create :addon

    addon_1_dependency_in_latest_version = create :addon
    addon_1_older_version = create :addon_version, addon: addon_1_dependency_in_latest_version
    addon_1_latest_version = create :addon_version, addon: addon_1_dependency_in_latest_version
    addon_1_dependency_in_latest_version.latest_addon_version = addon_1_latest_version
    addon_1_dependency_in_latest_version.save!

    expected_dependency = create :addon_version_dependency, package_addon: addon_to_look_up, addon_version: addon_1_latest_version

    addon_2_dependency_in_old_version = create :addon
    create :addon_version, addon: addon_2_dependency_in_old_version
    addon_2_latest_version = create :addon_version, addon: addon_2_dependency_in_old_version
    addon_2_dependency_in_old_version.latest_addon_version = addon_2_latest_version
    addon_2_dependency_in_old_version.save!

    create :addon_version_dependency, package_addon: addon_to_look_up, addon_version: addon_1_older_version

    addon_3_hidden = create :addon, hidden: true
    hidden_addon_latest_version = create :addon_version, addon: addon_3_hidden
    addon_3_hidden.latest_addon_version = hidden_addon_latest_version
    addon_3_hidden.save!

    create :addon_version_dependency, package_addon: addon_to_look_up, addon_version: hidden_addon_latest_version

    get '/api/v2/addon-dependencies', params: { filter: { package_addon_id: addon_to_look_up.id } }

    parsed_response = json_response
    assert_equal 1, parsed_response['data'].length, 'All addon dependents are returned'

    first_addon_dependency_response = parsed_response['data'][0]
    assert_equal expected_dependency.id.to_s, first_addon_dependency_response['id']
  end

  test 'addon dependencies filtered by default to exclude non-addons and hidden addons' do
    addon_dependency = create :addon_version_dependency, :is_addon
    create :addon_version_dependency, :is_not_addon

    get '/api/v2/addon-dependencies'

    parsed_response = json_response
    assert_equal 1, parsed_response['data'].length, 'One addon dependency is returned'

    assert_equal addon_dependency.id.to_s, parsed_response['data'][0]['id']
  end

  test 'hidden addon dependencies are not returned' do
    addon_dependency = create :addon_version_dependency, :is_addon
    addon_dependency.package_addon.update(hidden: false)

    hidden_addon_dependency = create :addon_version_dependency, :is_addon
    hidden_addon_dependency.package_addon.update(hidden: true)

    get '/api/v2/addon-dependencies'

    parsed_response = json_response
    assert_equal 1, parsed_response['data'].length, 'Only unhidden addon dependency is returned'

    assert_equal addon_dependency.id.to_s, parsed_response['data'][0]['id']
  end

  test 'end user can fetch non-addon addon dependencies' do
    addon_dependency = create :addon_version_dependency, :is_addon
    non_addon_addon_dependency = create :addon_version_dependency, :is_not_addon

    get '/api/v2/addon-dependencies', params: { filter: { visible_addons_only: false } }

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

  test 'end user request can include latest addon size of the dependency' do
    package_addon = create :addon
    latest_version = create :addon_version, addon: package_addon
    older_version = create :addon_version, addon: package_addon

    latest_size = create :addon_size, addon_version: latest_version, app_js_size: 50
    create :addon_size, addon_version: older_version, app_js_size: 75

    package_addon.latest_addon_version = latest_version
    package_addon.save!

    dependent_addon = create :addon
    dependent_version = create :addon_version, addon: dependent_addon

    create :addon_version_dependency, package_addon: package_addon, addon_version: dependent_version

    include = 'package-addon.latest-addon-version.addon-size'
    get '/api/v2/addon-dependencies', params: { filter: { addon_version_id: dependent_version.id }, include: include }

    parsed_response = json_response
    assert_equal 1, parsed_response['data'].length, 'One addon dependency is returned'

    included_sizes = parsed_response['included'].find_all { |datum| datum['type'] == 'addon-sizes' }

    assert_equal 1, included_sizes.length, 'One addon size is returned'
    assert_equal latest_size.app_js_size, included_sizes[0]['attributes']['app-js-size'], 'Latest addon size is returned'
  end
end
