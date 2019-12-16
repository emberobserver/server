# frozen_string_literal: true

class SizeCalculationQueueController < ApplicationController
  before_action :authenticate_server

  def get_calculation
    current_build = PendingSizeCalculation.find_by(build_server: @build_server)
    if current_build
      render json: current_build
      return
    end

    if PendingSizeCalculation.unassigned.count == 0
      head :no_content
      return
    end

    oldest_build = PendingSizeCalculation.oldest_unassigned(1).first
    oldest_build.build_server = @build_server
    oldest_build.build_assigned_at = DateTime.now
    oldest_build.save

    render json: oldest_build
  end
end
