# frozen_string_literal: true

require 'test_helper'

class API::V2::AddonSizesControllerTest < ControllerTest

  test 'can fetch addon_sizes for a list of addons' do
    addon = create :addon, name: 'blah'
    addon_version = create :addon_version, addon: addon
    create :addon_size, addon_version: addon_version

    get :index, params: { addon_ids: [addon.id] }

    assert_response :no_content
  end

end
