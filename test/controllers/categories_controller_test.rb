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

  test "responds with HTTP 422 when required data is missing" do
    post_as_user users(:admin), :create, category: { description: 'New category description' }
    assert_response :unprocessable_entity
  end

  test "creates a category when logged in and all required data is provided" do
    assert_difference 'Category.count' do
      post_as_user users(:admin), :create, category: { name: 'New category', description: 'New category description', position: -1 }
    end
  end

  test "responds with HTTP 201 (created) when new category is created" do
    post_as_user users(:admin), :create, category: { name: 'New category', description: 'New category description', position: -1 }
    assert_response :created
  end

  test "includes JSON with new category data in response after creating a new category" do
    post_as_user users(:admin), :create, category: { name: 'New category', description: 'New category description', position: -1 }
    assert_equal 'New category', json_response['category']['name']
  end

  test "moves categories as needed to insert a new one" do
    post_as_user users(:admin), :create, category: { name: 'New category at front', position: 1 }
    assert_equal 1, json_response['category']['position'], "the new category should be at the first position"
    assert_equal 2, categories(:first).position, "the previous first-position category should be at the second position"
    assert_equal 1, categories(:subcategory).position, "the position of subcategories shoud not have changed"
  end

  test "does not update category positions when a new category can't be saved" do
    post_as_user users(:admin), :create, category: { name: '', position: 1 }
    assert_equal 1, categories(:first).position
  end

  test "responds with HTTP 401 unauthorized when trying to update a category while not logged in" do
    put :update, id: categories(:first), category: { name: 'Blah' }
    assert_response :unauthorized
  end

  test "updates a category" do
    id = categories(:first).id
    put_as_user users(:admin), :update, id: id, category: { name: 'New category name' }
    assert_equal 'New category name', Category.find(id).name
  end

  test "responds with new category information in JSON after updating" do
    put_as_user users(:admin), :update, id: categories(:first), category: { name: 'Modified category name', description: 'Modified category description' }
    assert_equal 'Modified category name', json_response['category']['name']
    assert_equal 'Modified category description', json_response['category']['description']
  end

  test "responds with HTTP 404 (not found) when trying to update an invalid category" do
    put_as_user users(:admin), :update, id: -1, category: { name: 'blah' }
    assert_response :not_found
  end

  test "responds with HTTP 422 when trying to update category and required data is missing" do
    put_as_user users(:admin), :update, id: categories(:first), category: { name: '' }
    assert_response :unprocessable_entity
  end

  test "can update the position of a category" do
    id = categories(:first).id
    put_as_user users(:admin), :update, id: id, category: { position: 4 }
    assert_equal 4, Category.find(id).position
  end

  test "moving the first category moves the next one to the first position" do
    put_as_user users(:admin), :update, id: categories(:first), category: { position: 4 }
    assert_equal 1, categories(:top_level).position
  end

  test "updating a category's position updates other categories' appropriately" do
    put_as_user users(:admin), :update, id: categories(:top_level), category: { position: -1 }
    assert_equal 1, categories(:first).position, "Preceding categories' positions are left unchanged"
    assert_equal 2, categories(:parent).position, "Following categories' positions are decremented"
  end

  private

  def json_response
    @json_response ||= ActiveSupport::JSON.decode(@response.body)
  end

  def add_auth_token_to_request(user)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(user.auth_token)
  end

  def post_as_user(user, action, params)
    add_auth_token_to_request(user)
    post action, params
  end

  def put_as_user(user, action, params)
    add_auth_token_to_request(user)
    put action, params
  end
end
