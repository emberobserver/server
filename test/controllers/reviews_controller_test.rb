require 'test_helper'

class ReviewsControllerTest < ControllerTest
	test "returns HTTP 401 (unauthorized) when an unauthorized user tries to add a review" do
		post :create, review: { version_id: addon_versions(:basic_one_point_one), has_tests: 0 }
		assert_response :unauthorized
	end

	test "creating a review updates an addon's score" do
		post_as_user users(:admin), :create, review: { version_id: addon_versions(:basic_one_point_one), has_tests: 0, has_readme: 1, is_more_than_empty_addon: 0, is_open_source: 0, has_build: 0 }
		assert_equal 1, addons(:basic).score
	end

	test "creating a review creates a background task to regenerate the addons cache" do
		assert_enqueued_with job: AddonCacheBuilder do
			post_as_user users(:admin), :create, review: { version_id: addon_versions(:basic_one_point_one), has_tests: 0, has_readme: 1, is_more_than_empty_addon: 0, is_open_source: 0, has_build: 0 }
		end
	end
end
