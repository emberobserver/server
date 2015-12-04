require 'test_helper'

class AddonVersionTest < ActiveSupport::TestCase
	test 'uses the most recent review for a version' do
		addon_version = addon_versions(:basic_one_point_one)

		travel_to 1.day.ago do
			Review.create!(addon_version_id: addon_version.id, review: 'older')
		end
		Review.create!(addon_version_id: addon_version.id, review: 'newer')

		assert_equal 'newer', addon_version.review.review
	end
end
