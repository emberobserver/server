# frozen_string_literal: true

class SizeCalculationResultsController < ApplicationController
  before_action :authenticate_server, only: [:create]
  before_action :authenticate_user, only: [:retry]
  before_action :find_result, only: [:retry]

  def create
    begin
      size_calculation = PendingSizeCalculation.find(params[:pending_size_calculation_id])
    rescue ActiveRecord::RecordNotFound
      head :not_found
      return
    end

    if size_calculation.build_server != @build_server
      head :forbidden
      return
    end

    unless params[:status]
      head :unprocessable_entity
      return
    end

    if !succeeded? && !params[:output]
      head :unprocessable_entity
      return
    end

    if succeeded? && !parse_asset_sizes(params[:results])
      head :unprocessable_entity
      return
    end

    ActiveRecord::Base.transaction do
      SizeCalculationResult.create!(
        addon_version_id: size_calculation.addon_version.id,
        succeeded: succeeded?,
        output: params[:output],
        build_server: size_calculation.build_server,
        error_message: params[:error_message]
      )

      if succeeded?
        create_addon_size(size_calculation.addon_version)
      end

      size_calculation.destroy!
    end

    head :ok
  end

  def retry
    PendingSizeCalculation.create!(addon_version_id: @result.addon_version_id)
    head :created
  end

  private

  def find_result
    @result = SizeCalculationResult.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def succeeded?
    params[:status] == 'succeeded'
  end

  def parse_asset_sizes(json_string)
    @asset_sizes = JSON.parse(json_string)
  rescue JSON::ParserError
    false
  end

  def create_addon_size(addon_version)
    AddonSize.create!(
      addon_version_id: addon_version.id,
      app_js_size: @asset_sizes['appJsSize'],
      app_js_gzip_size: @asset_sizes['appJsGzipSize'],
      app_css_size: @asset_sizes['appCssSize'],
      app_css_gzip_size: @asset_sizes['appCssGzipSize'],
      vendor_js_size: @asset_sizes['vendorJsSize'],
      vendor_js_gzip_size: @asset_sizes['vendorJsGzipSize'],
      vendor_css_size: @asset_sizes['vendorCssSize'],
      vendor_css_gzip_size: @asset_sizes['vendorCssGzipSize'],
      other_js_size: @asset_sizes['otherJsSize'],
      other_js_gzip_size: @asset_sizes['otherJsGzipSize'],
      other_css_size: @asset_sizes['otherCssSize'],
      other_css_gzip_size: @asset_sizes['otherCssGzipSize'],
      other_assets: @asset_sizes['otherAssets']
    )
  end
end
