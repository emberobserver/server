class VersionsController < ApplicationController

  def index
    if params[:addon_id]
      addon_versions = Addon.find(params[:addon_id]).addon_versions
    else
      addon_versions = AddonVersion.all
    end

    render json: addon_versions
  end

  def show
		@addon_version = AddonVersion.find(params[:id])
		render json: @addon_version
	end
end
