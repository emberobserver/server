# frozen_string_literal: true

require 'test_helper'

class API::V2::BuildResultTest < IntegrationTest
  test 'getting list of build servers requires an authorized user' do
    create_list(:build_server, 3)

    get '/api/v2/build-servers'

    assert_response :forbidden
  end

  test "'index' action returns list of build servers" do
    create_list(:build_server, 3)

    authenticated_get '/api/v2/build-servers'
    assert_response :success

    assert_equal 3, json_response['data'].length
  end

  test 'adding a build server requires an authorized user' do
    assert_no_difference 'BuildServer.count' do
      create_build_server(attrs: { name: 'new-build-server' })
    end

    assert_response :forbidden
  end

  test 'creates a new build server when all required data is provided' do
    assert_difference 'BuildServer.count' do
      create_build_server(
        attrs: { name: 'new-build-server' },
        headers: auth_header
      )
    end

    assert_response :created

    assert_equal 'new-build-server', json_response['data']['attributes']['name']
  end

  test 'responds with HTTP 422 when some required data is missing while trying to create a build server' do
    assert_no_difference 'BuildServer.count' do
      create_build_server(
        attrs: { name: '' },
        headers: auth_header
      )
    end

    assert_response :unprocessable_entity
  end

  test 'updating a build server requires an authorized user' do
    build_server = create(:build_server)

    update_build_server(build_server.id,
      attrs: { name: 'new-name' })

    assert_response :forbidden
    assert_not_equal 'new-name', BuildServer.find(build_server.id).name
  end

  test 'can update the name for a build server' do
    build_server = create(:build_server)

    update_build_server(build_server.id,
      attrs: { name: 'new-name' },
      headers: auth_header)

    assert_response :success
    assert_equal 'new-name', BuildServer.find(build_server.id).name
    assert_equal 'new-name', json_response['data']['attributes']['name']
  end

  test 'responds with HTTP 404 when trying to update a nonexistent build server' do
    build_server = create(:build_server)

    update_build_server(build_server.id + 1,
      attrs: { name: 'abc' },
      headers: auth_header)

    assert_response :not_found
  end

  test 'responds with HTTP 422 when some required data is missing while trying to update a build server' do
    build_server = create(:build_server)

    update_build_server(build_server.id,
      attrs: { name: '' },
      headers: auth_header)

    assert_response :unprocessable_entity
    assert_not_empty BuildServer.find(build_server.id).name
  end

  test 'deleting a build server requires an authorized user' do
    build_server = create(:build_server)

    assert_no_difference 'BuildServer.count' do
      delete_build_server(build_server.id)
    end

    assert_response :forbidden
  end

  test 'can delete a build server' do
    build_server = create(:build_server)
    assert_difference 'BuildServer.count', -1 do
      delete_build_server(build_server.id, headers: auth_header)
    end

    assert_response :no_content
  end

  test 'responds with HTTP 404 when trying to delete a nonexistent build server' do
    delete_build_server(1, headers: auth_header)

    assert_response :not_found
  end

  private

  def auth_header
    authentication_headers_for(create(:user))
  end

  def authenticated_get(url)
    get url, headers: auth_header
  end

  def create_build_server(options)
    post '/api/v2/build-servers', params: {
      data: {
        type: 'build-servers',
        attributes: options[:attrs] || {}
      }
    }.to_json,
                                  headers: { CONTENT_TYPE: JSONAPI_TYPE }.merge(options[:headers] || {})
  end

  def delete_build_server(id, options = {})
    delete "/api/v2/build-servers/#{id}", headers: options[:headers] || {}
  end

  def update_build_server(id, options)
    patch "/api/v2/build-servers/#{id}", params: {
      data: {
        type: 'build-servers',
        id: id,
        attributes: options[:attrs] || {}
      }
    }.to_json,
                                         headers: { CONTENT_TYPE: JSONAPI_TYPE }.merge(options[:headers] || {})
  end
end
