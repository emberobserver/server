class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  protected

  include TokenAuth

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
end
