# frozen_string_literal: true

require 'test_helper'

class SizeCalculationResultsControllerTest < ControllerTest
  include BuildServerAuthHelper
  setup :create_pending_calculation

  test 'responds with HTTP unauthorized if request does not include token' do
    post :create

    assert_response :unauthorized
  end

  test 'responds with HTTP forbidden if the build was for a different build server' do
    other_build_server = create(:build_server)
    other_pending_calculation = create(:pending_size_calculation, addon_version: create(:addon_version), build_server: other_build_server)

    authed_post :create, pending_size_calculation_id: other_pending_calculation.id

    assert_response :forbidden
  end

  test 'responds with HTTP 404 when build does not exist' do
    authed_post :create, pending_size_calculation_id: 'foo'

    assert_response :not_found
  end

  test 'responds with HTTP 422 (unprocessable entity) when status is missing' do
    authed_post :create, pending_size_calculation_id: @pending_calculation.id, results: asset_size_result

    assert_response :unprocessable_entity
  end

  test 'does not require a results param when status is failed' do
    authed_post :create, pending_size_calculation_id: @pending_calculation.id, status: 'failed', output: 'missing Git tag'

    assert_response :ok
  end

  test ' "requires output param when status is failed"' do
    authed_post :create, pending_size_calculation_id: @pending_calculation.id, status: 'failed'

    assert_response :unprocessable_entity
  end

  test 'records the correct information when a failed build is reported' do
    authed_post :create, pending_size_calculation_id: @pending_calculation.id, status: 'failed', output: 'Install failed', error_message: 'Something unexpected happened'

    calculation_result = SizeCalculationResult.find_by(addon_version_id: @pending_calculation.addon_version.id)
    assert_equal false, calculation_result.succeeded?
    assert_equal 'Install failed', calculation_result.output
    assert_equal 'Something unexpected happened', calculation_result.error_message
  end

  test 'records the correct information when a successful build is reported' do
    authed_post :create, pending_size_calculation_id: @pending_calculation.id, status: 'succeeded', results: asset_size_result

    test_result = SizeCalculationResult.find_by(addon_version_id: @pending_calculation.addon_version.id)
    assert_equal true, test_result.succeeded?
  end

  test 'responds with HTTP 422 (unprocessable entity) when results is not a valid JSON string' do
    authed_post :create, pending_size_calculation_id: @pending_calculation.id, status: 'succeeded', results: 'foobar'

    assert_response :unprocessable_entity
  end

  test 'reporting results removes the pending calculation from the queue' do
    assert_difference 'PendingSizeCalculation.count', -1 do
      authed_post :create, pending_size_calculation_id: @pending_calculation.id, status: 'succeeded', results: asset_size_result
    end
  end

  test 'reporting results adds the results to the DB' do
    test_result_str = asset_size_result

    assert_difference 'SizeCalculationResult.count' do
      authed_post :create, pending_size_calculation_id: @pending_calculation.id, status: 'succeeded', results: test_result_str
    end
  end

  test 'reporting successful result creates AddonSize' do
    test_result_str = asset_size_result

    assert_difference 'AddonSize.count' do
      authed_post :create, pending_size_calculation_id: @pending_calculation.id, status: 'succeeded', results: test_result_str
    end

    addon_size = AddonSize.find_by(addon_version_id: @pending_calculation.addon_version.id)
    # %({"appJsSize":"1960","vendorJsSize":"0","otherJsSize":"200","appCssSize":"1428","vendorCssSize":"420","otherCssSize":"0"})
    assert_equal 1960, addon_size.app_js_size
    assert_equal 0, addon_size.vendor_js_size
    assert_equal 200, addon_size.other_js_size

    assert_equal 1428, addon_size.app_css_size
    assert_equal 420, addon_size.vendor_css_size
    assert_equal 0, addon_size.other_css_size
  end

  test 'saves build server ID with record result' do
    authed_post :create, pending_size_calculation_id: @pending_calculation.id, status: 'succeeded', results: asset_size_result

    assert_equal build_server, SizeCalculationResult.find_by(addon_version_id: @pending_calculation.addon_version_id).build_server
  end

  private

  def create_pending_calculation
    addon_version = create(:addon_version)
    @pending_calculation = create(:pending_size_calculation, addon_version: addon_version, build_server: build_server, build_assigned_at: 5.minutes.ago)
  end

  def build_server
    @build_server ||= create(:build_server)
  end

  def asset_size_result
    %({"appJsSize":"1960","vendorJsSize":"0","otherJsSize":"200","appCssSize":"1428","vendorCssSize":"420","otherCssSize":"0"})
  end
end
