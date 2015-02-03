class MetricsController < ApplicationController
  def index
    metrics = Metric.all
    render json: metrics
  end
end
