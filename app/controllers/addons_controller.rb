class AddonsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :authenticate, only: [:update]

  def index
    addons = Addon.includes(:maintainers).where(hidden: false).all
    render json: addons
  end

  def show
    addon = Addon.find(params[:id])
    render json: addon
  end

  def update
    addon = Addon.find(params[:id])
    addon.update({category_ids: params[:addon][:categories],
                  note: params[:addon][:note],
                  official: params[:addon][:is_official],
                  deprecated: params[:addon][:is_deprecated],
                  cli_dependency: params[:addon][:is_cli_dependency],
                  hidden: params[:addon][:is_hidden]
                 })
    render json: addon
  end

  private

  def addon_params
    params.require(:addon).permit(:categories, :note, :official, :deprecated, :cli_dependency, :hidden)
  end
end
