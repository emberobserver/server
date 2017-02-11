module TokenAuth
  def authenticate
    authenticate_user
  end

  def authenticate_user
    authenticate_user_token || render_unauthorized
  end

  def authenticate_server
    authenticate_server_token || render_unauthorized
  end

  def authenticate_server_token
    authenticate_with_http_token do |token|
      @build_server = BuildServer.find_by(token: token)
    end
  end

  def authenticate_user_token
    authenticate_with_http_token do |token, options|
      User.find_by(auth_token: token)
    end
  end

  def current_user
    @_current_user ||= authenticate_user_token
  end

  def render_unauthorized
    self.headers['WWW-Authenticate'] = 'Token realm="Application"'
    render json: 'Bad credentials', status: 401
  end
end
