class AddonsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :authenticate, only: [:update, :hidden]

  def index
    if params[:hidden]
      redirect_to :hidden and return
    end

    render_cached_json 'api:addons:index' do
      AddonCacheBuilder.new.build_json
    end
  end

  def hidden
    addons = Addon.includes(:maintainers).includes(:addon_versions).where(hidden: true).where('name not ilike ?', '%murray%').all
    render json: addons
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
    regenerate_caches
    if params[:addon][:has_invalid_github_repo] && addon.github_stats
      addon.github_stats.delete
    end
    render json: addon
  end

  private

  def render_markdown(text)
    GitHub::Markdown.to_html(text, :gfm)
  end
end
