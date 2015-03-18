class ReadmesController < ApplicationController

  def index
    if params[:addon_id]
      readme = Addon.find(params[:addon_id]).github_stats.readme
      render json: {
        readmes: [{
          id: params[:addon_id],
          addon_id: params[:addon_id],
          text: readme
        }]
      }
    else
      head :bad_request
    end
  end

end
