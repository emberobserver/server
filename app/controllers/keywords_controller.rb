class KeywordsController < ApplicationController
  def index
    keywords = NpmKeyword.all
    render json: keywords
  end

  def show
    keyword = NpmKeyword.find(params[:id])
    render json: keyword
  end
end
