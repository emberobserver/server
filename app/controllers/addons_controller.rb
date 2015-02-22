class AddonsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :authenticate, only: [:update]

  def index
    render_cached_json 'api:addons:index', expires_in: 1.hour do
      addons = Addon.includes(:maintainers).includes(:addon_versions).where(hidden: false).all
      ActiveModel::Serializer.build_json(self, addons, { })
    end
  end

  def show
    addon = Addon.where(name: params[:name]).first
    if addon
      render json: addon
    else
      head :not_found
    end
  end

  def update
    addon = Addon.find(params[:id])
    category_ids = categories_with_parents(params[:addon][:categories])
    addon.update({category_ids: category_ids,
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

  def categories_with_parents(category_ids)
    all_category_ids = [ ]
    category_ids.each do |category_id|
      category = Category.find(category_id)
      all_category_ids << category.id
      all_category_ids << category.parent_id if category.parent_id
    end
    all_category_ids
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
