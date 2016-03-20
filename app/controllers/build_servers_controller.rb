class BuildServersController < ApplicationController
  before_action :authenticate

  def index
    render json: BuildServer.all
  end

  def create
    new_build_server = BuildServer.new(build_server_params)
    if new_build_server.save
      render json: new_build_server, status: :created
    else
      render json: { errors: new_build_server.errors }, status: :unprocessable_entity
    end
  end

  def update
    begin
      build_server = BuildServer.find(params[:id])
    rescue
      head :not_found
      return
    end

    if build_server.update_attributes(build_server_params)
      render json: build_server
    else
      render json: { errors: build_server.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    begin
      build_server = BuildServer.find(params[:id])
    rescue
      head :not_found
      return
    end

    build_server.destroy

    head :no_content
  end

  private

  def build_server_params
    params.require(:build_server).permit(:name)
  end
end
