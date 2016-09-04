class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  protected

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

  def regenerate_caches
    AddonCacheBuilder.perform_later
    CategoryCacheBuilder.perform_later
  end

  def render_cached_json(cache_key, options = { }, &block)
    options[:expires_in] ||= 2.hours

    expires_in options[:expires_in], public: true
    data = Rails.cache.fetch(cache_key, options) do
      block.call
    end

    render json: data
  end

  def render_unauthorized
    self.headers['WWW-Authenticate'] = 'Token realm="Application"'
    render json: 'Bad credentials', status: 401
  end
end
