class AddonsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :authenticate, only: [:update]

  def index
    render_cached_json 'api:addons:index' do
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
    addon.update({category_ids: params[:addon][:categories],
                  note: params[:addon][:note],
                  rendered_note: render_markdown(params[:addon][:note]),
                  official: params[:addon][:is_official],
                  deprecated: params[:addon][:is_deprecated],
                  cli_dependency: params[:addon][:is_cli_dependency],
                  hidden: params[:addon][:is_hidden],
                  has_invalid_github_repo: params[:addon][:has_invalid_github_repo]
                 })
    invalidate_caches
    if params[:addon][:has_invalid_github_repo] && addon.github_stats
      addon.github_stats.delete
    end
    render json: addon
  end

  private

  def addon_params
    params.require(:addon).permit(:categories, :note, :official, :deprecated, :cli_dependency, :hidden)
  end

  def render_markdown(text)
    GitHub::Markdown.to_html(text, :gfm)
  end
end
