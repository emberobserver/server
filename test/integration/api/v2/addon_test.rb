# frozen_string_literal: true

require 'test_helper'

class API::V2::AddonTest < IntegrationTest
  ADDON_ATTRIBUTES = %w[
    name
    latest-version-date
    description
    is-deprecated
    is-official
    is-cli-dependency
    is-hidden
    score
    is-wip
    is-fully-loaded
    ranking
    published-date
    repository-url
    license
    note
    has-invalid-github-repo
    last-month-downloads
    is-top-downloaded
    is-top-starred
    demo-url
  ].freeze

  ADDON_RELATIONSHIPS = %w[
    maintainers
    versions
    keywords
    github-users
    reviews
    categories
    github-stats
    readme
  ].freeze

  test 'end user can fetch addons with filter' do
    create_list :addon, 3, ranking: 2
    hidden_addon = create :addon, :hidden, ranking: 4

    get '/api/v2/addons', params: { filter: { top: true } }

    assert_response 200

    parsed_response = json_response
    assert_equal 3, parsed_response['data'].length

    addon_ids = parsed_response['data'].map { |d| d['id'] }
    assert_equal 3, addon_ids.length, 'There are three addon ids'
    assert_not_includes addon_ids, hidden_addon.id, 'Hidden addons are not included in response'

    first_addon_response = parsed_response['data'][0]
    assert_equal first_addon_response['attributes'].keys, ADDON_ATTRIBUTES, 'Addon response includes expected fields'
    assert_equal first_addon_response['relationships'].keys, ADDON_RELATIONSHIPS, 'Addon response includes expected relationships'
  end

  test 'end user can fetch individual addon' do
    addon = create :addon

    get "/api/v2/addons/#{addon.id}"

    assert_response 200

    parsed_response = json_response

    assert_equal addon.id.to_s, parsed_response['data']['id'], 'Addon is returned'

    first_addon_response = parsed_response['data']
    assert_equal first_addon_response['attributes'].keys, ADDON_ATTRIBUTES, 'Addon response includes expected fields'
    assert_equal first_addon_response['relationships'].keys, ADDON_RELATIONSHIPS, 'Addon response includes expected relationships'
  end

  test 'end user can fetch an individual addon with some included resources' do
    addon = create :addon
    addon_version = create :addon_version, addon: addon
    create :review, addon_version: addon_version

    get "/api/v2/addons/#{addon.id}", params: { include: 'versions,maintainers,keywords,reviews,reviews.version,categories' }

    assert_response 200
  end

  test 'end user cannot update addons with no attributes' do
    addon = create :addon

    update_addon(addon)

    assert_response 403, 'End user cannot update with empty attrs'
  end

  test 'end user cannot update addons with some attributes' do
    addon = create :addon

    ADDON_ATTRIBUTES.each do |field|
      attrs = {}
      attrs[field] = "Updated #{field}"

      update_addon(addon, attrs: attrs)

      assert_response 400, "End user cannot update #{field}"
      assert_match /#{field}/, json_response['errors'][0]['detail'], "#{field} cannot be updated"
    end
  end

  test 'end user cannot update addons with some relationships' do
    addon = create :addon

    ADDON_RELATIONSHIPS.each do |relationship|
      relationships = {}
      relationships[relationship] = {
        data: {
          type: relationship,
          id: 1
        }
      }

      update_addon(addon, relationships: relationships)

      assert_response 400, "End user cannot update #{relationship}"
      assert_match /#{relationship}/, json_response['errors'][0]['detail'], "#{relationship} cannot be updated"
    end
  end

  test 'end user cannot delete addons' do
    addon = create :addon

    assert_no_difference 'Addon.count' do
      delete "/api/v2/addons/#{addon.id}"
    end

    assert_response 403, 'Deleting addons is not permitted'
  end

  test 'end user cannot create addons with no attributes' do
    assert_no_difference 'Addon.count' do
      post '/api/v2/addons', params: {
        data: {
          type: 'addons',
          attributes: {}
        }
      }.to_json,
                             headers: { CONTENT_TYPE: JSONAPI_TYPE }
    end

    assert_response 403, 'Creating addons is not permitted'
  end

  test 'end user cannot create addons with some attributes' do
    ADDON_ATTRIBUTES.each do |field|
      attrs = {}
      attrs[field] = "New #{field}"
      assert_no_difference 'Addon.count' do
        post '/api/v2/addons/',
          params: {
            data: {
              type: 'addons',
              attributes: attrs
            }
          }.to_json,
          headers: { CONTENT_TYPE: JSONAPI_TYPE }
      end
      assert_response 400, "End user cannot create addon with #{field}"
      assert_match /#{field}/, json_response['errors'][0]['detail'], "Cannot created addon with #{field}"
    end
  end

  test 'end user cannot create addons with some relationships' do
    ADDON_RELATIONSHIPS.each do |relationship|
      relationships = {}
      relationships[relationship] = {
        data: {
          type: relationship,
          id: 1
        }
      }

      assert_no_difference 'Addon.count' do
        post '/api/v2/addons',
          params: {
            data: {
              type: 'addons',
              relationships: relationships
            }
          }.to_json,
          headers: { CONTENT_TYPE: JSONAPI_TYPE }
      end

      assert_response 400, "End user cannot create addon with relationship #{relationship}"
      assert_match /#{relationship}/, json_response['errors'][0]['detail'], "addon cannot be created with #{relationship}"
    end
  end

  test 'admin user cannot update addons with not permitted attributes' do
    addon = create :addon

    updatable_attributes_as_keys = API::V2::AddonResource::UPDATABLE_ATTRIBUTES.map(&:to_s).map(&:dasherize)

    auth_headers = authentication_headers_for(create(:user))

    (ADDON_ATTRIBUTES - updatable_attributes_as_keys).each do |field|
      attrs = {}
      attrs[field] = "Updated #{field}"

      update_addon(addon, attrs: attrs, headers: auth_headers)

      assert_response 400, "Admin user cannot update #{field}"
      assert_match /#{field}/, json_response['errors'][0]['detail'], "#{field} cannot be updated, even by admin"
    end
  end

  test 'admin user cannot update addons with not permitted relationships' do
    addon = create :addon
    auth_headers = authentication_headers_for(create(:user))
    updatable_relationships_as_keys = API::V2::AddonResource::UPDATABLE_RELATIONSHIPS.map(&:to_s).map(&:dasherize)

    (ADDON_RELATIONSHIPS - updatable_relationships_as_keys).each do |relationship|
      relationships = {}
      relationships[relationship] = {
        data: {
          type: relationship,
          id: 1
        }
      }

      update_addon(addon, relationships: relationships, headers: auth_headers)

      assert_response 400, "End user cannot update #{relationship}"
      assert_match /#{relationship}/, json_response['errors'][0]['detail'], "#{relationship} cannot be updated"
    end
  end

  test 'admin user can update addons with permitted attributes' do
    addon = create :addon

    updatable_attributes_as_keys = API::V2::AddonResource::UPDATABLE_ATTRIBUTES.map(&:to_s).map(&:dasherize)

    auth_headers = authentication_headers_for(create(:user))

    attrs = {
      'is-deprecated' => true,
      'is-official' => true,
      'is-cli-dependency' => true,
      'is-hidden' => true,
      'is-wip' => true,
      'note' => 'This is an updated note',
      'has-invalid-github-repo' => true
    }

    update_addon(addon, attrs: attrs, headers: auth_headers)

    assert_response 200, 'Admin user CAN update permitted fields'
    assert_equal attrs.keys, updatable_attributes_as_keys, 'All keys that can be updated should be tested'
    addon.reload

    assert_equal true, addon.deprecated
    assert_equal true, addon.official
    assert_equal true, addon.cli_dependency
    assert_equal true, addon.hidden
    assert_equal true, addon.is_wip
    assert_equal 'This is an updated note', addon.note
    assert_equal true, addon.has_invalid_github_repo
  end

  test 'admin user can update addons with permitted relationships' do
    addon = create :addon
    auth_headers = authentication_headers_for(create(:user))
    updatable_relationships_as_keys = API::V2::AddonResource::UPDATABLE_RELATIONSHIPS.map(&:to_s).map(&:dasherize)
    category = create(:category)

    relationships = {}
    relationships['categories'] = {
      data: [
        {
          type: 'categories',
          id: category.id
        }
      ]
    }

    update_addon(addon, relationships: relationships, headers: auth_headers)

    assert_response 200, 'Admin user CAN update permitted relationships'
    assert_equal relationships.keys, updatable_relationships_as_keys, 'All relationships that can be updated should be tested'
    addon.reload
    assert_equal [category.id], addon.categories.map(&:id)
  end

  test 'admin user can filter addons by hidden' do
    create :addon
    create :addon, :hidden
    create :addon, :hidden

    auth_headers = authentication_headers_for(create(:user))

    get '/api/v2/addons', params: { filter: { hidden: true } }, headers: auth_headers

    assert_response 200

    parsed_response = json_response
    assert_equal 2, parsed_response['data'].length

    addon_ids = parsed_response['data'].map { |d| d['id'] }
    assert_equal 2, addon_ids.length, 'There are two hidden addons'
  end

  test 'admin user can filter by being not categorized' do
    auth_headers = authentication_headers_for(create(:user))

    category = create :category, name: 'Parent Category'
    other_category = create :category, name: 'Other category'
    create :addon, name: 'test-foo', categories: []
    create :addon, name: 'test-bah', categories: [other_category]
    create :addon, name: 'test-zoo', categories: []
    create :addon, name: 'test-raa', categories: [category, other_category]

    get '/api/v2/addons', params: { filter: { notCategorized: true } }, headers: auth_headers

    assert_response_only_contains_these_addons(%w[test-zoo test-foo])
  end

  test 'admin user can filter by not reviewed' do
    auth_headers = authentication_headers_for(create(:user))

    reviewed_addon = create :addon, name: 'test-foo'
    create :addon_version, :with_review, addon: reviewed_addon

    not_reviewed_addon = create :addon, name: 'test-bah'
    create :addon_version, addon: not_reviewed_addon

    get '/api/v2/addons', params: { filter: { notReviewed: true } }, headers: auth_headers

    assert_response_only_contains_these_addons(%w[test-bah])
  end

  test 'admin user can filter by needs re-review' do
    auth_headers = authentication_headers_for(create(:user))

    needs_re_review_addon = create :addon, name: 'test-review-me'
    create :addon_version, :with_review, addon: needs_re_review_addon
    latest_addon_version = create :addon_version, addon: needs_re_review_addon
    needs_re_review_addon.latest_addon_version = latest_addon_version
    needs_re_review_addon.save!

    does_not_need_re_review_addon = create :addon, name: 'test-bah'
    create :addon_version, addon: does_not_need_re_review_addon
    latest_addon_version_b = create :addon_version, :with_review, addon: does_not_need_re_review_addon
    does_not_need_re_review_addon.latest_addon_version = latest_addon_version_b
    does_not_need_re_review_addon.save!

    another_needs_re_review_addon = create :addon, name: 'test-foo'
    create :addon_version, :with_review, addon: another_needs_re_review_addon
    latest_addon_version_c = create :addon_version, addon: another_needs_re_review_addon
    another_needs_re_review_addon.latest_addon_version = latest_addon_version_c
    another_needs_re_review_addon.save!

    get '/api/v2/addons', params: { filter: { needsReReview: true } }, headers: auth_headers

    assert_response_only_contains_these_addons(%w[test-foo test-review-me])
  end

  test 'end user cannot filter by needs re-review' do
    get '/api/v2/addons', params: { filter: { needsReReview: true } }

    assert_response 403, 'End user cannot use not needs re-review filter'
  end

  test 'end user cannot filter by not reviewed' do
    get '/api/v2/addons', params: { filter: { notReviewed: true } }

    assert_response 403, 'End user cannot use not reviewed filter'
  end

  test 'end user cannot filter by not categorized' do
    get '/api/v2/addons', params: { filter: { notCategorized: true } }

    assert_response 403, 'End user cannot use not categorized filter'
  end

  test 'end user cannot filter by hidden' do
    create :addon
    create :addon, :hidden
    create :addon, :hidden

    get '/api/v2/addons', params: { filter: { hidden: true } }

    assert_response 403, 'End user cannot use hidden filter'
  end

  test 'end user can filter by name' do
    create :addon, name: 'test-foo'
    create :addon, name: 'test-bah'

    get '/api/v2/addons', params: { filter: { name: 'test-foo' } }

    assert_response_only_contains_these_addons(%w[test-foo])
  end

  test 'end user can filter by being in category' do
    category = create :category, name: 'Parent Category'
    other_category = create :category, name: 'Other category'
    create :addon, name: 'test-foo', categories: [category, other_category]
    create :addon, name: 'test-bah', categories: [other_category]
    create :addon, name: 'test-zoo', categories: [category]

    get '/api/v2/addons', params: { filter: { inCategory: category.id } }

    assert_response_only_contains_these_addons(%w[test-zoo test-foo])
  end

  test 'end user can filter by top ranking' do
    create :addon, name: 'test-foo', ranking: 3
    create :addon, name: 'test-bah', ranking: 0
    create :addon, name: 'test-zoo', ranking: nil

    get '/api/v2/addons', params: { filter: { top: true } }

    assert_response_only_contains_these_addons(%w[test-foo test-bah])
  end

  test 'end user can filter by is_wip' do
    create :addon, name: 'test-foo', is_wip: false
    create :addon, name: 'test-bah', is_wip: true

    get '/api/v2/addons', params: { filter: { isWip: true } }

    assert_response_only_contains_these_addons(%w[test-bah])
  end

  test 'end user can filter by recently reviewed' do
    12.times do |n|
      reviewed = create :addon, name: "test-#{n}"
      reviewed_version = create :addon_version, addon: reviewed
      create :review, addon_version: reviewed_version
    end

    get '/api/v2/addons', params: { filter: { recentlyReviewed: true } }

    assert_response_only_contains_these_addons(%w[test-10 test-11 test-2 test-3 test-4 test-5 test-6 test-7 test-8 test-9])
  end

  test 'end user can filter by recently reviewed with a limit greater than 10' do
    12.times do |n|
      reviewed = create :addon, name: "test-#{n}"
      reviewed_version = create :addon_version, addon: reviewed
      create :review, addon_version: reviewed_version
    end

    get '/api/v2/addons', params: { filter: { recentlyReviewed: true }, page: { limit: 100 } }

    assert_response_only_contains_these_addons(%w[test-0 test-10 test-11 test-1 test-2 test-3 test-4 test-5 test-6 test-7 test-8 test-9])
  end

  test 'end user cannot fetch all addons' do
    get '/api/v2/addons'

    assert_response 403, 'End user cannot fetch all addons'
  end

  test 'end user can fetch all addons with a limit and a sort' do
    create_list :addon, 15

    get '/api/v2/addons', params: { page: { limit: 10 }, sort: '-publishedDate' }

    assert_response 200, 'End user can fetch all addons with sort and limit'
    assert_equal 10, json_response['data'].length, 'Responds with limit # of addons'
  end

  test 'no relationship routes' do
    addon = create :addon
    assert_raises ActionController::RoutingError do
      post "/api/v2/addons/#{addon.id}/relationships/categories"
    end
  end

  private

  def assert_response_only_contains_these_addons(addon_names)
    assert_response 200
    parsed_response = json_response
    assert_equal addon_names.length, parsed_response['data'].length, "#{addon_names.length} addons in results"
    addons_in_response_names = parsed_response['data'].map do |res|
      res['attributes']['name']
    end
    assert_equal addon_names.sort, addons_in_response_names.sort, 'Only these addons are in response'
  end

  def update_addon(addon, options = {})
    patch "/api/v2/addons/#{addon.id}",
      params: {
        data: {
          type: 'addons',
          id: addon.id,
          attributes: options[:attrs] || {},
          relationships: options[:relationships] || {}
        }
      }.to_json,
      headers: { CONTENT_TYPE: JSONAPI_TYPE }.merge(options[:headers] || {})
  end
end

### Holy gotchas

# If providing any attrs, gets caught by creatable_fields and updateable_fields on the resource
# No attrs -> addon processor
