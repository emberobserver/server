class API::V2::JsonapiBaseController < JSONAPI::ResourceController
  before_action :allow_page_caching

  private

  def allow_page_caching
    if request.get?
      expires_in(1.hour, public: true)
    end
  end
end
