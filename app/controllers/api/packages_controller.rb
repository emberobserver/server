class API::PackagesController < ApplicationController
  def index
    @packages = Package.all
    render json: @packages
  end

  def show
    @package = Package.find(params[:id])
    render json: @package
  end
end
