class AddonsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :authenticate, only: [:update]

  def index
    addons = Addon.all
    render json: addons
  end

  def show
    addon = Addon.find(params[:id])
    render json: addon
  end

  #TODO: Secure this for admin only
  def update
    addon = Addon.find(params[:id])
    addon.update({category_ids: params[:addon][:categories]})
    render json: addon
  end

  private

  def addon_params
    params.require(:addon).permit(:categories)
  end
end
