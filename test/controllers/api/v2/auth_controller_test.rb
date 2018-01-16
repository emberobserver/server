require 'test_helper'

class API::V2::AuthControllerTest < ControllerTest

  test "user can log in" do
    user = create :user, email: 'test@example.com', password: 'abc123', auth_token: nil

    post :login, params: { email: 'test@example.com', password: 'abc123' }

    assert_response 200
    assert user.reload.auth_token
  end

  test "user cannot log in without correct password" do
    user = create :user, email: 'test@example.com', password: 'abc123', auth_token: nil

    post :login, params: { email: 'test@example.com', password: 'wrong' }

    assert_response 401
    assert !user.reload.auth_token
  end

  test "user can log out" do
    user = create :user, auth_token: 'something'

    post_as_user user, :logout

    assert_response 200
    assert !user.reload.auth_token
  end
end
