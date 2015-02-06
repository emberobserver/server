class PackagesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :authenticate, only: [:update]

  def index
    packages = Package.includes(:package_versions).all
    render json: packages, each_serializer: PackagesSerializer
  end

  def show
    package = Package.includes(:package_versions).find(params[:id])
    render json: package
  end

  #TODO: Secure this for admin only
  def update
    package = Package.find(params[:id])
    package.update({category_ids: params[:package][:categories]})
    render json: package
  end

  private

  def package_params
    params.require(:package).permit(:categories)
  end
end
