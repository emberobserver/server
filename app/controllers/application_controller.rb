class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  protected

  def authenticate
    authenticate_token || render_unauthorized
  end

  def authenticate_token
    authenticate_with_http_token do |token, options|
      User.find_by(auth_token: token)
    end
  end

  def invalidate_caches
    Rails.cache.delete 'api:addons:index'
    Rails.cache.delete 'api:categories:index'
  end

  def render_cached_json(cache_key, options = { }, &block)
    options[:expires_in] ||= 1.hour

    expires_in options[:expires_in], public: true
    data = Rails.cache.fetch(cache_key, { raw: true }.merge(options)) do
      block.call.to_json
    end

    render json: data
  end

  def render_unauthorized
    self.headers['WWW-Authenticate'] = 'Token realm="Application"'
    render json: 'Bad credentials', status: 401
  end
end
