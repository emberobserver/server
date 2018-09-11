# frozen_string_literal: true

require 'test_helper'

class API::V2::ReviewTest < IntegrationTest
  REVIEW_ATTRIBUTES = %w[
    created-at
    has-tests
    has-readme
    is-more-than-empty-addon
    review
    is-open-source
    has-build
  ].freeze

  REVIEW_RELATIONSHIPS = %w[
    version
  ].freeze

  test 'end user cannot fetch reviews' do
    assert_raises ActionController::RoutingError do
      get '/api/v2/reviews'
    end
  end

  test 'end user cannot fetch individual review' do
    addon = create :addon
    addon_version = create :addon_version, addon: addon
    review = create :review, addon_version: addon_version
    assert_raises ActionController::RoutingError do
      get "/api/v2/reviews/#{review.id}"
    end
  end

  test 'end user cannot update individual review' do
    addon = create :addon
    addon_version = create :addon_version, addon: addon
    review = create :review, addon_version: addon_version
    assert_raises ActionController::RoutingError do
      patch "/api/v2/reviews/#{review.id}"
    end
  end

  test 'end user cannot create review' do
    create_review({})

    assert_response 403
  end

  test 'admin user can create review' do
    version = create :addon_version, addon: create(:addon)
    auth_headers = authentication_headers_for(create(:user))

    create_review(
      attrs: {
        "has-tests": 1,
        "has-readme": 2,
        "is-more-than-empty-addon": 3,
        "is-open-source": 2,
        "has-build": 3,
        "review": 'A review'
      },
      relationships: {
        version: { data: { type: 'versions', id: version.id } }
      },
      headers: auth_headers
    )

    assert_response 201
  end

  test 'end user can fetch an addons review' do
    addon = create :addon
    addon_version = create :addon_version, addon: addon
    review = create :review, addon_version: addon_version
    addon.latest_review = review
    addon.save

    get "/api/v2/addons/#{addon.id}/latest-review"

    review_response = json_response['data']
    assert_equal review_response['attributes'].keys, REVIEW_ATTRIBUTES, 'Review response includes expected fields'
    assert_equal review_response['relationships'].keys, REVIEW_RELATIONSHIPS, 'Review response includes expected relationships'
  end

  test 'end user cannot delete review' do
    addon = create :addon
    addon_version = create :addon_version, addon: addon
    review = create :review, addon_version: addon_version

    assert_raises ActionController::RoutingError, 'Reviews only have create routes' do
      delete "/api/v2/reviews/#{review.id}", headers: { CONTENT_TYPE: JSONAPI_TYPE }
    end
  end

  private

  def create_review(options)
    post '/api/v2/reviews',
      params: {
        data: {
          type: 'reviews',
          attributes: options[:attrs] || {},
          relationships: options[:relationships] || {}
        }
      }.to_json,
      headers: { CONTENT_TYPE: JSONAPI_TYPE }.merge(options[:headers] || {})
  end
end
