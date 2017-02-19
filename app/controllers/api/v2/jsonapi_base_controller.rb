class API::V2::JsonapiBaseController < JSONAPI::ResourceController
  include TokenAuth
  after_action :allow_page_caching

  def context
    { current_user: current_user }
  end

  private

  def allow_page_caching
    if current_user.nil? && request.get?
      if [200, 301, 302].include?(response.code)
        expires_in(1.hour, public: true)
      end
    end
  end
end
