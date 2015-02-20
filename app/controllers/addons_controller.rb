class AddonsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :authenticate, only: [:update]

  def index
    render_cached_json 'api:addons:index', expires_in: 1.hour do
      addons = Addon.includes(:maintainers).where(hidden: false).all
      ActiveModel::ArraySerializer.new(addons, each_serializer: AddonSerializer)
    end
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

  def render_cached_json(cache_key, options = { }, &block)
    options[:expires_in] ||= 1.day

    expires_in options[:expires_in], public: true
    data = Rails.cache.fetch(cache_key, { raw: true }.merge(options)) do
      block.call.to_json
    end

    render json: data
  end
end
