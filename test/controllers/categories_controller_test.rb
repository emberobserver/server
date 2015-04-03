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
end
