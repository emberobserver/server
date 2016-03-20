require 'test_helper'

class BuildServersControllerTest < ControllerTest
  test "getting list of build servers requires an authorized user" do
    create_list(:build_server, 3)

    get :index

    assert_response :unauthorized
  end

  test "'index' action returns list of build servers" do
    create_list(:build_server, 3)

    get_as_user create(:user), :index
    assert_response :success

    assert_equal 3, json_response['build_servers'].length
  end

  test "adding a build server requires an authorized user" do
    assert_no_difference 'BuildServer.count' do
      post :create, build_server: { name: 'new-build-server' }
    end

    assert_response :unauthorized
  end

  test "creates a new build server when all required data is provided" do
    assert_difference 'BuildServer.count' do
      post_as_user create(:user), :create, build_server: { name: 'new-build-server' }
    end

    assert_response :created

    assert_equal 'new-build-server', json_response['build_server']['name']
  end

  test "responds with HTTP 422 when some required data is missing while trying to create a build server" do
    assert_no_difference 'BuildServer.count' do
      post_as_user create(:user), :create, build_server: { name: '' }
    end

    assert_response :unprocessable_entity
  end

  test "updating a build server requires an authorized user" do
    build_server = create(:build_server)

    put :update, id: build_server.id, build_server: { name: 'new-name' }

    assert_response :unauthorized
    assert_not_equal 'new-name', BuildServer.find(build_server.id).name
  end

  test "can update the name for a build server" do
    build_server = create(:build_server)

    put_as_user create(:user), :update, id: build_server.id, build_server: { name: 'new-name' }

    assert_response :success
    assert_equal 'new-name', BuildServer.find(build_server.id).name
    assert_equal 'new-name', json_response['build_server']['name']
  end

  test "responds with HTTP 404 when trying to update a nonexistent build server" do
    build_server = create(:build_server)

    put_as_user create(:user), :update, id: build_server.id+1, build_server: { name: 'abc' }

    assert_response :not_found
  end

  test "responds with HTTP 422 when some required data is missing while trying to update a build server" do
    build_server = create(:build_server)

    put_as_user create(:user), :update, id: build_server.id, build_server: { name: '' }

    assert_response :unprocessable_entity
    assert_not_empty BuildServer.find(build_server.id).name
  end

  test "deleting a build server requires an authorized user" do
    build_server = create(:build_server)

    assert_no_difference 'BuildServer.count' do
      delete :destroy, id: build_server.id
    end

    assert_response :unauthorized
  end

  test "can delete a build server" do
    build_server = create(:build_server)
    assert_difference 'BuildServer.count', -1 do
      delete_as_user create(:user), :destroy, id: build_server.id
    end

    assert_response :no_content
  end

  test "responds with HTTP 404 when trying to delete a nonexistent build server" do
    delete_as_user create(:user), :destroy, id: 1

    assert_response :not_found
  end
  #
  # test "should get destroy" do
  #   get :destroy
  #   assert_response :success
  # end

end
