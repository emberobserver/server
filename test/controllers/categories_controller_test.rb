require 'test_helper'

class CategoriesControllerTest < ControllerTest
  test "'show' returns data for a top-level category" do
    category = create :category

    get :show, name: category.name
    assert_response :success

    assert_equal category.name, json_response['category']['name']
    assert_equal category.description, json_response['category']['description']
  end

  test "'show' response includes parent category for a subcategory" do
    subcategory = create :subcategory
    parent = subcategory.parent_category

    get :show, name: subcategory.name

    assert_equal parent.reload.id, json_response['category']['parent_id']
  end

  test "'show' response includes IDs of subcategories when category has some" do
    category = create :parent_category
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
    post_as_user create(:user), :create, category: { description: 'New category description' }
    assert_response :unprocessable_entity
  end

  test "response body includes error messages when a new category fails to be created" do
    post_as_user create(:user), :create, category: { description: 'Blah' }
    assert_not_empty json_response['errors']
  end

  test "creates a category when logged in and all required data is provided" do
    assert_difference 'Category.count' do
      post_as_user create(:user), :create, category: { name: 'New category', description: 'New category description', position: -1 }
    end
  end

  test "responds with HTTP 201 (created) when new category is created" do
    post_as_user create(:user), :create, category: { name: 'New category', description: 'New category description', position: -1 }
    assert_response :created
  end

  test "includes JSON with new category data in response after creating a new category" do
    post_as_user create(:user), :create, category: { name: 'New category', description: 'New category description', position: -1 }
    assert_equal 'New category', json_response['category']['name']
  end

  test "moves categories as needed to insert a new one" do
    first = create :category
    subcategory = create :subcategory

    post_as_user create(:user), :create, category: { name: 'New category at front', position: 1 }
    assert_equal 1, json_response['category']['position'], "the new category should be at the first position"
    assert_equal 2, first.reload.position, "the previous first-position category should be at the second position"
    assert_equal 1, subcategory.reload.position, "the position of subcategories shoud not have changed"
  end

  test "does not update category positions when a new category can't be saved" do
    first = create :category

    post_as_user create(:user), :create, category: { name: '', position: 1 }

    assert_equal 1, first.reload.position
  end

  test "responds with HTTP 401 unauthorized when trying to update a category while not logged in" do
    put :update, id: create(:category).id, category: { name: 'Blah' }
    assert_response :unauthorized
  end

  test "updates a category" do
    id = create(:category).id
    put_as_user create(:user), :update, id: id, category: { name: 'New category name' }
    assert_equal 'New category name', Category.find(id).name
  end

  test "responds with new category information in JSON after updating" do
    put_as_user create(:user), :update, id: create(:category), category: { name: 'Modified category name',
      description: 'Modified category description' }
    assert_equal 'Modified category name', json_response['category']['name']
    assert_equal 'Modified category description', json_response['category']['description']
  end

  test "responds with HTTP 404 (not found) when trying to update an invalid category" do
    put_as_user create(:user), :update, id: -1, category: { name: 'blah' }
    assert_response :not_found
  end

  test "responds with HTTP 422 when trying to update category and required data is missing" do
    put_as_user create(:user), :update, id: create(:category), category: { name: '' }
    assert_response :unprocessable_entity
  end

  test "includes error messages in JSON response body after failing to update a category" do
    put_as_user create(:user), :update, id: create(:category), category: { name: '' }
    assert_not_empty json_response['errors']
  end

  test "can update the position of a category" do
    id = create(:category).id
    put_as_user create(:user), :update, id: id, category: { position: 4 }
    assert_equal 4, Category.find(id).position
  end

  test "moving the first category moves the next one to the first position" do
    first = create :category
    second = create :category
    put_as_user create(:user), :update, id: first, category: { position: 4 }
    assert_equal 1, second.reload.position
  end

  test "updating a category's position updates other categories' appropriately" do
    first = create :category
    second = create :category
    third = create :category

    put_as_user create(:user), :update, id: second, category: { position: -1 }
    assert_equal 1, first.reload.position, "Preceding categories' positions are left unchanged"
    assert_equal 2, third.reload.position, "Following categories' positions are decremented"
  end

  test "can update the parent of a category" do
    subcategory = create :subcategory
    parent = subcategory.parent_category

    put_as_user create(:user), :update, id: subcategory, category: { parent_id: nil }

    parent.reload
    assert_equal 0, parent.subcategories.count
  end

  test "updating a category's parent moves it to the end" do
    category = create :subcategory
    create_list :category, 3
    last_position = Category.last.position

    put_as_user create(:user), :update, id: category, category: { parent_id: nil }
    assert_equal last_position + 1, category.reload.position
  end

  test "after updating a category's parent, doesn't leave gaps in positions for the old parent" do
    first = create :category
    second = create :category
    parent = create :parent_category

    put_as_user create(:user), :update, id: first, category: { parent_id: parent.id }
    assert_equal 1, second.reload.position
  end

  private

  def json_response
    @json_response ||= ActiveSupport::JSON.decode(@response.body)
  end
end
