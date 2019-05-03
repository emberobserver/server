module BuildServerAuthHelper

  def build_server
    @build_server ||= create(:build_server)
  end

  def authed_post(action, data = {})
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(build_server.token)
    post action, params: data
  end

end
