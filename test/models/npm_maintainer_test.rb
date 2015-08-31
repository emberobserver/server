require 'test_helper'

class NpmMaintainerTest < ActiveSupport::TestCase
  test "hidden addons are not includes in maintainer's addons" do
		maintainer = NpmMaintainer.create(name: 'maintainer')
		maintainer.addons.create(name: 'hidden addon', hidden: true)
		maintainer.addons.create(name: 'visible addon')

		assert_equal 1, maintainer.visible_addons.count
		assert_equal 'visible addon', maintainer.visible_addons.first.name
  end
end
