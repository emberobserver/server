# == Schema Information
#
# Table name: addon_versions
#
#  id                :integer          not null, primary key
#  addon_id          :integer
#  version           :string
#  released          :datetime
#  addon_name        :string
#  ember_cli_version :string
#

require 'test_helper'

class AddonVersionTest < ActiveSupport::TestCase
  test 'uses the most recent review for a version' do
    addon_version = create :addon_version, :basic_one_point_one

    travel_to 1.day.ago do
      Review.create!(addon_version_id: addon_version.id, review: 'older')
    end
    Review.create!(addon_version_id: addon_version.id, review: 'newer')

    assert_equal 'newer', addon_version.review.review
  end

  test "latest_test_result excludes canary-only results" do
    addon_version = create(:addon_version)
    full_suite_results = create(:test_result, addon_version: addon_version, canary: false, created_at: 10.minutes.ago)
    create(:test_result, addon_version: addon_version, canary: true, created_at: 5.minutes.ago)

    assert_equal full_suite_results.id, addon_version.latest_test_result.id
  end
end
