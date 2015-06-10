require 'test_helper'

class LatestVersionTest < ActiveSupport::TestCase
  test "package names are unique" do
    LatestVersion.create!(package: 'blah', version: '1.0.0')
    assert_raises ActiveRecord::RecordInvalid do
      LatestVersion.create!(package: 'blah', version: '1.0.0')
    end
  end
end
