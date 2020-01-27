# frozen_string_literal: true

class TestResultsController < ApplicationController
  before_action :authenticate_server, only: [:create]
  before_action :authenticate_user, only: [:retry]
  before_action :find_test_result, only: [:retry]

  def create
    begin
      build = PendingBuild.find(params[:pending_build_id])
    rescue ActiveRecord::RecordNotFound
      head :not_found
      return
    end

    if build.build_server != @build_server
      head :forbidden
      return
    end

    unless params[:status]
      head :unprocessable_entity
      return
    end

    if !succeeded? && !params[:status_message]
      head :unprocessable_entity
      return
    end

    if succeeded? && !verify_test_results
      head :unprocessable_entity
      return
    end

    ActiveRecord::Base.transaction do
      semver_string = build.semver_string
      if build.canary?
        semver_string = nil
      end
      test_result = TestResult.create!(
        addon_version_id: build.addon_version.id,
        build_server: build.build_server,
        canary: build.canary?,
        ember_try_results: results,
        output: output,
        output_format: output_format,
        semver_string: semver_string,
        status_message: params[:status_message],
        succeeded: succeeded?
      )

      if succeeded?
        record_version_compatibilities(test_result)
      end

      build.destroy!
    end

    head :ok
  end

  def retry
    PendingBuild.create!(
      addon_version_id: @test_result.addon_version_id,
      canary: @test_result.canary?
    )

    head :created
  end

  private

  def find_test_result
    @test_result = TestResult.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def output
    if output_format == 'json'
      params[:output]
    else
      params[:output]&.read
    end
  end

  def output_format
    params[:format].blank? ? 'text' : params[:format].to_s
  end

  def succeeded?
    params[:status] == 'succeeded'
  end

  def results
    @results ||= begin
      JSON.parse(params[:results] || '')
    rescue JSON::ParserError
      return nil
    end
  end

  def verify_test_results
    return false if results.nil?
    return false if results['scenarios'].empty?
    true
  end

  def record_version_compatibilities(test_result)
    @results['scenarios'].each do |scenario|
      next if scenario['dependencies'].empty?
      ember_version = extract_ember_version(scenario)
      next if ember_version.blank?
      EmberVersionCompatibility.create!(test_result: test_result, ember_version: ember_version, compatible: scenario['passed'])
    end
  end

  def extract_ember_version(scenario)
    ember_dependency = scenario['dependencies'].select { |dep| dep['name'] == 'ember' || dep['name'] == 'ember-source' }.reject { |dep| dep['versionSeen'] == 'Not Installed' }.first
    ember_dependency.blank? ? nil : ember_dependency['versionSeen']
  end
end
