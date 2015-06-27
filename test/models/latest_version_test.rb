# == Schema Information
#
# Table name: latest_versions
#
#  id         :integer          not null, primary key
#  package    :string
#  version    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class LatestVersionTest < ActiveSupport::TestCase
  test "package names are unique" do
    LatestVersion.create!(package: 'blah', version: '1.0.0')
    assert_raises ActiveRecord::RecordInvalid do
      LatestVersion.create!(package: 'blah', version: '1.0.0')
    end
  end
end
