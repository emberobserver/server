class MaintainersController < ApplicationController
  def index
    if params[:addon_id]
      maintainers = Addon.find(params[:addon_id]).maintainers
    else
      maintainers = NpmUser.includes(:addons).all
    end

    render json: maintainers
  end
end
