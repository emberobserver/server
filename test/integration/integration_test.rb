class IntegrationTest < ActionDispatch::IntegrationTest
  JSONAPI_TYPE = "application/vnd.api+json"

  setup do
    @integration_session = open_session
    @integration_session.accept = JSONAPI_TYPE
  end

  protected

  def json_response
    ActiveSupport::JSON.decode(@response.body)
  end

  def authentication_headers_for(user = create(:user))
    {
      'HTTP_AUTHORIZATION': ActionController::HttpAuthentication::Token.encode_credentials(user.auth_token)
    }
  end
end
