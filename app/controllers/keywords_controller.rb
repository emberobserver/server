class KeywordsController < ApplicationController
  def index
    if params[:addon_id]
      keywords = Addon.find(params[:addon_id]).npm_keywords.includes(:addons)
    else
      keywords = NpmKeyword.all
    end

    render json: keywords
  end

  def show
    keyword = NpmKeyword.find(params[:id])
    render json: keyword
  end
end
