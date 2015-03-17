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
                  has_invalid_github_repo: params[:addon][:has_invalid_github_repo],
                  is_wip: params[:addon][:is_wip]
                 })
    invalidate_caches
    if params[:addon][:has_invalid_github_repo] && addon.github_stats
      addon.github_stats.delete
    end
    render json: addon
  end

  def readme
    addon = Addon.find(params[:addon_id])
    if addon and addon.github_stats
      render json: {
        addon: {
          id: params[:addon_id],
          readme: addon.github_stats.readme
        }
      }
    else
      head :not_found
    end
  end

  private

  def render_markdown(text)
    GitHub::Markdown.to_html(text, :gfm)
  end
end
