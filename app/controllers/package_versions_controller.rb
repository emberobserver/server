class PackageVersionsController < ApplicationController
	def show
		@package_version = PackageVersion.find(params[:id])
		render json: @package_version
	end
end
