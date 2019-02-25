# == Schema Information
#
# Table name: ember_versions
#
#  id         :integer          not null, primary key
#  version    :string           not null
#  released   :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class EmberVersionTest < ActiveSupport::TestCase
  test '.releases returns only versions without "beta" in the version number' do
    create_list :ember_version, 5, version: 'v1.0.0'
    create_list :ember_version, 3, version: 'v1.0.0.beta.1'

    assert_equal 5, EmberVersion.releases.count
  end

  test '.major_and_minor returns versions ending in .0' do
    create_list :ember_version, 2, :major
    create_list :ember_version, 3, :minor
    create_list :ember_version, 4, :beta
    create_list :ember_version, 6, :point_release

    assert_equal 5, EmberVersion.major_and_minor.count
  end
end
