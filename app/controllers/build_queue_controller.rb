class BuildQueueController < ApplicationController
  before_filter :authenticate

  def get_build
    current_build = PendingBuild.find_by(build_server: @build_server)
    if current_build
      render json: current_build
      return
    end

    if PendingBuild.unassigned.count == 0
      head :no_content
      return
    end

    oldest_build = PendingBuild.oldest_unassigned
    oldest_build.build_server = @build_server
    oldest_build.build_assigned_at = DateTime.now
    oldest_build.save

    render json: oldest_build
  end

  private

  def authenticate_token
    authenticate_with_http_token do |token|
      @build_server = BuildServer.find_by(token: token)
    end
  end
end
