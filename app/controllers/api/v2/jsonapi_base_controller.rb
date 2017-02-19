class API::V2::JsonapiBaseController < JSONAPI::ResourceController
  include TokenAuth
  before_action :allow_page_caching

  def context
    { current_user: current_user }
  end

  private

  def allow_page_caching
    if current_user.nil? && request.get?
      expires_in(1.hour, public: true)
    end
  end
end
