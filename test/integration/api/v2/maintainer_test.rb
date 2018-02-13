# frozen_string_literal: true

require 'test_helper'

class API::V2::MaintainerTest < IntegrationTest
  MAINTAINER_ATTRIBUTES = %w[
    name
    gravatar
  ].freeze

  MAINTAINER_RELATIONSHIPS = %w[
    addons
  ].freeze

  test 'end user can fetch an individual maintainer by name' do
    NpmMaintainer.create!(name: 'Jsmith')

    get '/api/v2/maintainers', params: { filter: { name: 'Jsmith' } }

    assert_response 200
    maintainer_response = json_response['data'][0]
    assert_equal maintainer_response['attributes'].keys, MAINTAINER_ATTRIBUTES, 'Maintainer response includes expected fields'
    assert_equal maintainer_response['relationships'].keys, MAINTAINER_RELATIONSHIPS, 'Maintainer response includes expected relationships'
  end

  test 'end user cannot fetch all the maintainers' do
    get '/api/v2/maintainers'
    assert_response 403, 'End user cannot fetch all maintainers'
  end

  test 'end user cannot fetch individual maintainer' do
    maintainer = NpmMaintainer.create!(name: 'Jsmith')
    assert_raises ActionController::RoutingError do
      get "/api/v2/maintainers/#{maintainer.id}"
    end
  end

  test 'end user cannot update individual maintainer' do
    maintainer = NpmMaintainer.create!(name: 'Jsmith')

    assert_raises ActionController::RoutingError do
      patch "/api/v2/maintainers/#{maintainer.id}"
    end
  end

  test 'end user cannot create maintainer' do
    assert_raises ActionController::RoutingError do
      post '/api/v2/maintainers'
    end
  end

  test 'end user cannot delete maintainer' do
    maintainer = NpmMaintainer.create!(name: 'Jsmith')

    assert_raises ActionController::RoutingError do
      delete "/api/v2/maintainers/#{maintainer.id}"
    end
  end
end
