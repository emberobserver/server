class ControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper

  protected
  def json_response
    @json_response ||= ActiveSupport::JSON.decode(@response.body)
  end

  def get_as_user(user, action, params={})
    authenticate(user)
    get action, params: params
  end

  def post_as_user(user, action, params={})
    authenticate(user)
    post action, params: params
  end

  def put_as_user(user, action, params={})
    authenticate(user)
    put action, params: params
  end

  def delete_as_user(user, action, params={})
    authenticate(user)
    delete action, params: params
  end

  private
  def authenticate(user)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(user.auth_token)
  end
end
