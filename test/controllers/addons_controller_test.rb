require 'test_helper'

class AddonsControllerTest < ControllerTest
	test "'index' action returns data for non-hidden addons" do
		get :index
		assert_response :success

		assert_equal 3, json_response['addons'].length
		json_response['addons'].each do |addon_json|
			assert_not_equal addons(:hidden).id, addon_json['id']
		end
	end

	test "'show' returns data for an addon" do
		addon = addons(:basic)
		get :show, name: addon.name
		assert_response :success

		assert_equal addon.id, json_response['addon']['id']
		assert_equal addon.name, json_response['addon']['name']
	end

	test "'show' responds with an HTTP 404 when an invalid addon is requested" do
		get :show, name: "I don't exist"
		assert_response :not_found
	end

	test "individual addon response includes maintainer data" do
		get :show, name: addons(:basic).name
		assert_not_nil json_response['maintainers']
	end

	test "unauthorized users cannot update addon information" do
		put :update, id: addons(:basic), addon: { is_hidden: true }
		assert_response :unauthorized
		assert_equal false, addons(:basic).hidden
	end

	test "authorized users can update addon information" do
		put_as_user users(:admin), :update, id: addons(:basic), addon: { is_hidden: true }
		assert_response :success
		addons(:basic).reload
		assert_equal true, addons(:basic).hidden
	end

	test "unauthorized users cannot get a list of hidden addons" do
		get :hidden
		assert_response :unauthorized
	end

	test "authorized users can get a list of hidden addons" do
		get_as_user users(:admin), :hidden
		assert_response :success
		assert_equal 1, json_response['addons'].length
	end
end
