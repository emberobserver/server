require 'test_helper'

class AddonsControllerTest < ControllerTest
	test "'index' action returns data for non-hidden addons" do
    create_list :addon, 3
    hidden_addon = create :addon, :hidden

		get :index
		assert_response :success

		assert_equal 3, json_response['addons'].length
		json_response['addons'].each do |addon_json|
			assert_not_equal hidden_addon.id, addon_json['id']
		end
	end

	test "'show' returns data for an addon" do
		addon = create :addon, :basic
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
		get :show, name: create(:addon).name
		assert_not_nil json_response['maintainers']
	end

	test "unauthorized users cannot update addon information" do
    addon = create :addon

		put :update, id: addon.id, addon: { is_hidden: true }

		assert_response :unauthorized
    addon.reload
		assert_equal false, addon.hidden
	end

	test "authorized users can update addon information" do
    addon = create :addon

    put_as_user create(:user), :update, id: addon.id, addon: { is_hidden: true }
		assert_response :success
		addon.reload
		assert_equal true, addon.hidden
	end

	test "unauthorized users cannot get a list of hidden addons" do
		get :hidden
		assert_response :unauthorized
	end

	test "authorized users can get a list of hidden addons" do
    create :addon, :hidden
		get_as_user create(:user), :hidden
		assert_response :success
		assert_equal 1, json_response['addons'].length
	end
end
