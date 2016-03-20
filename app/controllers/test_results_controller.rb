class TestResultsController < ApplicationController
  before_filter :authenticate

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

    if succeeded? && !verify_test_results(params[:results])
      head :unprocessable_entity
      return
    end

    test_result = TestResult.create(addon_version_id: build.addon_version.id, succeeded: succeeded?, status_message: params[:status_message])

    if succeeded?
      record_version_compatibilities test_result
    end

    build.destroy

    head :ok
  end

  private

  def succeeded?
    params[:status] == 'succeeded'
  end

  def authenticate_token
    authenticate_with_http_token do |token|
      @build_server = BuildServer.find_by(token: token)
    end
  end

  def verify_test_results(results_str)
    begin
      @results = JSON.parse(results_str)
    rescue JSON::ParserError
      return false
    end

    return false if @results['scenarios'].empty?
    true
  end

  def record_version_compatibilities(test_result)
    @results['scenarios'].each do |scenario|
      next if scenario['dependencies'].empty?
      ember_version = extract_ember_version(scenario)
      EmberVersionCompatibility.create test_result: test_result, ember_version: ember_version, compatible: scenario['passed']
    end
  end

  def extract_ember_version(scenario)
    scenario['dependencies'].select { |dep| dep['name'] == 'ember' }.first['versionSeen']
  end
end
