class ReadmesController < ApplicationController

  def show
    readme = Readme.find(params[:id])
    render json: readme
  end

end
