# frozen_string_literal: true

require 'test_helper'

class API::V2::CategoryTest < IntegrationTest
  CATEGORY_ATTRIBUTES = %w[
    name
    description
    position
    addon-count
  ].freeze

  CATEGORY_RELATIONSHIPS = %w[
    subcategories
    parent
    addons
  ].freeze

  test 'end user can fetch categories' do
    create_list :category, 10

    get '/api/v2/categories'

    parsed_response = json_response
    assert_equal 10, parsed_response['data'].length, 'All categories are returned'

    first_category_response = parsed_response['data'][0]
    assert_equal first_category_response['attributes'].keys, CATEGORY_ATTRIBUTES, 'Category response includes expected fields'
    assert_equal first_category_response['relationships'].keys, CATEGORY_RELATIONSHIPS, 'Category response includes expected relationships'
  end

  test 'end user can fetch individual category' do
    category = create :category

    get "/api/v2/categories/#{category.id}"

    assert_response 200
    assert_equal category.id.to_s, json_response['data']['id']
  end

  test 'end user cannot update individual category' do
    new_parent = create :category
    category = create :category

    update_category(category, {
                      attrs: {
                        "name": "Updated cat",
                        "description": "An updated thing",
                        "position": 2
                      },
                      relationships: {
                        parent: { data: { type: "categories", id: new_parent.id } },
                      }
                    })

    assert_response 400, 'Responds with 400 for non-permitted attributes'
  end

  test 'end user cannot update individual category with no data' do
    category = create :category

    update_category(category, {
                      attrs: {},
                      relationships: {}
                    })

    assert_response 403, 'Responds with 403 when it hits the category processor'
  end

  test 'end user cannot create category' do
    create_category({})

    assert_response 403, 'Responds with 403 when it hits the category processor'
  end

  test 'admin user can create category' do
    existing_category_at_position_4 = create :category, position: 4
    parent = create :category
    auth_headers = authentication_headers_for(create(:user))

    assert_difference 'Category.count' do
      create_category(
        attrs: {
          "name": 'New cat',
          "description": 'A new thing',
          "position": 4
        },
        relationships: {
          parent: { data: { type: 'categories', id: parent.id } }
        },
        headers: auth_headers
      )
    end

    assert_response 201

    new_category = Category.last

    assert_equal 'New cat', new_category.name
    assert_equal 'A new thing', new_category.description
    assert_equal parent, new_category.parent_category
    assert_equal 4, new_category.position

    existing_category_at_position_4.reload
    assert_equal 5, existing_category_at_position_4.position
  end

  test "does not update category positions when a new category can't be saved" do
    first = create :category, position: 1

    auth_headers = authentication_headers_for(create(:user))
    create_category(
      attrs: {
        name: '',
        position: 1
      },
      relationships: {},
      headers: auth_headers
    )

    assert_response 422
    assert_equal 1, first.reload.position
  end

  test 'admin user can update category' do
    new_parent = create :category
    category = create :category
    auth_headers = authentication_headers_for(create(:user))

    update_category(category,
                    attrs: {
                      "name": 'Updated cat',
                      "description": 'An updated thing',
                      "position": 2
                    },
                    relationships: {
                      parent: { data: { type: 'categories', id: new_parent.id } }
                    },
                    headers: auth_headers)

    assert_response 200

    category.reload

    assert_equal 'Updated cat', category.name
    assert_equal 'An updated thing', category.description
    assert_equal new_parent, category.parent_category
    assert_equal 2, category.position
  end

  test 'admin user can delete category' do
    category = create :category
    auth_headers = authentication_headers_for(create(:user))

    assert_difference 'Category.count', -1 do
      delete_category(category,
                      headers: auth_headers)
    end

    assert_response 204
  end

  test 'end user cannot delete category' do
    category = create :category

    assert_no_difference 'Category.count' do
      delete_category(category)
    end

    assert_response 403
  end

  test 'moving the first category moves the next one to the first position' do
    first = create :category, position: 1
    second = create :category, position: 2

    auth_headers = authentication_headers_for(create(:user))

    update_category(first,
                    attrs: {
                      position: 4
                    },
                    relationships: {},
                    headers: auth_headers)

    assert_equal 1, second.reload.position
  end

  test "updating a category's parent moves it to the end" do
    category = create :subcategory
    create_list :category, 3
    last_position = Category.last.position

    auth_headers = authentication_headers_for(create(:user))

    update_category(category,
                    attrs: {
                      position: -1
                    },
                    relationships: {
                      parent: { data: nil }
                    },
                    headers: auth_headers)

    assert_equal last_position + 1, category.reload.position
  end

  test "after updating a category's parent, doesn't leave gaps in positions for the old parent" do
    first = create :category, position: 1
    second = create :category, position: 2
    parent = create :parent_category, position: 3

    skip 'This is not working currently and I am not sure how to make it work without messing with a category before_save and we cannot do that before the original API is retired'
    auth_headers = authentication_headers_for(create(:user))

    update_category(first,
                    attrs: {
                      position: -1
                    },
                    relationships: {
                      parent: {
                        data: {
                          type: 'categories',
                          id: parent.id
                        }
                      }
                    },
                    headers: auth_headers)

    assert_equal 1, second.reload.position
  end

  private

  def create_category(options)
    post '/api/v2/categories',
         params: {
           data: {
             type: 'categories',
             attributes: options[:attrs] || {},
             relationships: options[:relationships] || {}
           }
         }.to_json,
         headers: { CONTENT_TYPE: JSONAPI_TYPE }.merge(options[:headers] || {})
  end

  def update_category(category, options)
    patch "/api/v2/categories/#{category.id}",
          params: {
            data: {
              type: 'categories',
              id: category.id,
              attributes: options[:attrs] || {},
              relationships: options[:relationships] || {}
            }
          }.to_json,
          headers: { CONTENT_TYPE: JSONAPI_TYPE }.merge(options[:headers] || {})
  end

  def delete_category(category, options = {})
    delete "/api/v2/categories/#{category.id}", headers: { CONTENT_TYPE: JSONAPI_TYPE }.merge(options[:headers] || {})
  end
end
