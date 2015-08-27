class MaintainersController < ApplicationController
  def index
    if params[:addon_id]
      maintainers = Addon.find(params[:addon_id]).maintainers
      render json: maintainers
    else
      render_cached_json 'api:maintainers:index' do
        MaintainerCacheBuilder.new.build_json
      end
    end
  end

  def show
    maintainer = NpmMaintainer.find(params[:id])
    render json: maintainer
  end
end
