require 'test_helper'

class CategoriesControllerTest < ControllerTest
  test "'show' returns data for a top-level category" do
    category = categories(:top_level)

    get :show, name: category.name
    assert_response :success

    assert_equal category.name, json_response['category']['name']
    assert_equal category.description, json_response['category']['description']
  end

  test "'show' response includes parent category for a subcategory" do
    get :show, name: categories(:subcategory).name

    assert_equal categories(:parent).id, json_response['category']['parent_id']
  end

  test "'show' response includes IDs of subcategories when category has some" do
    category = categories(:parent)
    get :show, name: category.name

    assert_equal category.subcategories.length, json_response['category']['subcategory_ids'].length
    assert_equal category.subcategories.first.id, json_response['category']['subcategory_ids'].first
  end

  test "responds with HTTP 404 when nonexistent category is requested" do
    get :show, name: "I don't exist"
    assert_response :not_found
  end

  test "'index' response has categories sorted by position" do
    get :index

    assert_equal categories(:first).name, json_response['categories'].first['name']

    # because of a subcategory, we need to check at index 4 instead of 3 for the fourth top-level category
    assert_equal categories(:fourth).name, json_response['categories'][4]['name']

    assert_equal categories(:last).name, json_response['categories'].last['name']
  end

  test "responds with HTTP 401 when trying to create a category while not logged in" do
    post :create, category: { name: 'new category', description: 'New category description' }
    assert_response :unauthorized
  end

  test "responds with HTTP 422 when name is missing" do
    post_as_user users(:admin), :create, category: { name: '', description: 'New category description' }
    assert_response :unprocessable_entity
  end

  test "creates a category when logged in and all required data is provided" do
    assert_difference 'Category.count' do
      post_as_user users(:admin), :create, category: { name: 'New category', description: 'New category description' }
    end
  end

  test "responds with HTTP 201 (created) when new category is created" do
    post_as_user users(:admin), :create, category: { name: 'New category', description: 'New category description' }
    assert_response :created
  end

  private

  def post_as_user(user, action, params)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(user.auth_token)
    post action, params
  end
end
