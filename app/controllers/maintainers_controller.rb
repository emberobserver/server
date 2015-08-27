class MaintainersController < ApplicationController
  def index
    if params[:addon_id]
      maintainers = Addon.find(params[:addon_id]).maintainers
    else
      maintainers = NpmMaintainer.includes(:addons).all
    end

    render json: maintainers
  end

  def show
    maintainer = NpmMaintainer.find(params[:id])
    render json: maintainer
  end
end
