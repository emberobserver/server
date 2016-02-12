require 'test_helper'

class VersionsControllerTest < ControllerTest

  test 'can fetch all addon versions' do
    create_list :addon_version, 3

    get :index

    assert_response 200
    assert_equal 3, json_response['versions'].size
  end

  test 'can fetch the versions for an addon' do
    addon = create :addon
    create_list :addon_version, 3
    this_addon_versions = create_list :addon_version, 2, addon: addon

    get :index, addon_id: addon.id

    assert_response 200

    assert_equal 2, json_response['versions'].size
    expected_addon_ids = this_addon_versions.map { |version| version.id }

    json_response['versions'].each do |version|
      assert expected_addon_ids.include?(version['id']), 'Addon version should be included'
    end
  end

end
