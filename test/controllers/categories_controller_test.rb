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

  test "responds with HTTP 401 when trying to create a category while not logged in" do
    post :create, category: { name: 'new category', description: 'New category description' }
    assert_response :unauthorized
  end

  test "responds with HTTP 422 when required data is missing" do
    post_as_user users(:admin), :create, category: { description: 'New category description' }
    assert_response :unprocessable_entity
  end

  test "response body includes error messages when a new category fails to be created" do
    post_as_user users(:admin), :create, category: { description: 'Blah' }
    assert_not_empty json_response['errors']
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

  test "includes error messages in JSON response body after failing to update a category" do
    put_as_user users(:admin), :update, id: categories(:first), category: { name: '' }
    assert_not_empty json_response['errors']
  end

  test "can update the position of a category" do
    id = categories(:first).id
    put_as_user users(:admin), :update, id: id, category: { position: 4 }
    assert_equal 4, Category.find(id).position
  end

  test "moving the first category moves the next one to the first position" do
    put_as_user users(:admin), :update, id: categories(:first), category: { position: 4 }
    assert_equal 1, categories(:second).position
  end

  test "updating a category's position updates other categories' appropriately" do
    put_as_user users(:admin), :update, id: categories(:second), category: { position: -1 }
    assert_equal 1, categories(:first).position, "Preceding categories' positions are left unchanged"
    assert_equal 2, categories(:top_level).position, "Following categories' positions are decremented"
  end

  test "can update the parent of a category" do
    id = categories(:subcategory).id
    put_as_user users(:admin), :update, id: id, category: { parent_id: nil }
    assert_equal 0, categories(:parent).subcategories.count
  end

  test "updating a category's parent moves it to the end" do
    id = categories(:subcategory).id
    put_as_user users(:admin), :update, id: id, category: { parent_id: nil }
    assert_equal categories(:last).position + 1, Category.find(id).position
  end

  test "after updating a category's parent, doesn't leave gaps in positions for the old parent" do
    put_as_user users(:admin), :update, id: categories(:first), category: { parent_id: categories(:parent) }
    assert_equal 1, categories(:second).position
  end

  private

  def json_response
    @json_response ||= ActiveSupport::JSON.decode(@response.body)
  end
end
