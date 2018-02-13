# frozen_string_literal: true

# == Schema Information
#
# Table name: npm_maintainers
#
#  id         :integer          not null, primary key
#  name       :string
#  email      :string
#  gravatar   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class NpmMaintainerTest < ActiveSupport::TestCase
  test "hidden addons are not includes in maintainer's addons" do
    maintainer = NpmMaintainer.create!(name: 'maintainer')
    maintainer.addons << create(:addon, name: 'hidden addon', hidden: true)
    maintainer.addons << create(:addon, name: 'visible addon')

    assert_equal 1, maintainer.visible_addons.count
    assert_equal 'visible addon', maintainer.visible_addons.first.name
  end
end
