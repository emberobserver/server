# frozen_string_literal: true

class BuildQueueController < ApplicationController
  before_action :authenticate_server

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
end
