class AddonVersionsController < ApplicationController
	def show
		@addon_version = AddonVersion.find(params[:id])
		render json: @addon_version
	end
end
