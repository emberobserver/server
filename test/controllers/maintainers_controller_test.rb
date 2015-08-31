require 'test_helper'

class MaintainersControllerTest < ControllerTest
  test "only visible addons are included" do
    maintainer = NpmMaintainer.create(name: 'Mr. Maintainer')
    maintainer.addons.create(name: 'hidden addon', hidden: true)
    visible_addon = maintainer.addons.create(name: 'visible addon')

    get :index

    addon_ids = json_response['maintainers'].first['addon_ids']
    assert_equal 1, addon_ids.length
    assert_equal visible_addon.id, addon_ids.first
  end
end
