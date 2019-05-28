# frozen_string_literal: true

require 'test_helper'

class SizeCalculationQueueControllerTest < ControllerTest
  include BuildServerAuthHelper

  test "responds with HTTP unauthorized when request doesn't include a token" do
    post :get_calculation

    assert_response :unauthorized
  end

  test 'responds with HTTP 204 (no content) when no calculations are in the queue' do
    authed_post :get_calculation

    assert_response :no_content
  end

  test 'responds with HTTP 204 (no content) when the queue is not empty but all calculations are assigned' do
    addon_version = create(:addon_version)
    other_build_server = create(:build_server)
    create(:pending_size_calculation, addon_version: addon_version, build_server: other_build_server, build_assigned_at: 1.hour.ago)

    authed_post :get_calculation

    assert_response :no_content
  end

  test 'responds with calculation info for the oldest non-assigned calculation when queue is not empty' do
    addon = create(:addon)
    oldest_addon_version, middle_addon_version, newest_addon_version = create_list(:addon_version, 3, addon: addon)

    create :pending_size_calculation, addon_version: oldest_addon_version, created_at: 2.months.ago, build_server: create(:build_server), build_assigned_at: 2.months.ago
    create :pending_size_calculation, addon_version: middle_addon_version, created_at: 1.month.ago
    create :pending_size_calculation, addon_version: newest_addon_version, created_at: 1.hour.ago

    authed_post :get_calculation

    assert_response :success
    assert_equal addon.name, json_response['pending_size_calculation']['addon_name']
    assert_equal middle_addon_version.version, json_response['pending_size_calculation']['version']
  end

  test 'sets the build server and assigned date when a calculation is requested' do
    addon_version = create(:addon_version)
    pending_size_calculation = create(:pending_size_calculation, addon_version: addon_version)

    authed_post :get_calculation

    pending_size_calculation.reload

    assert_equal build_server.id, pending_size_calculation.build_server_id
    assert_not_nil pending_size_calculation.build_assigned_at
  end

  test 'returns the assigned build for a token that already has a build assigned' do
    addon_version = create(:addon_version)
    pending_size_calculation = create(:pending_size_calculation, addon_version: addon_version, build_server: build_server, build_assigned_at: 1.day.ago)

    authed_post :get_calculation

    assert_response :success
    assert_equal build_server.id, pending_size_calculation.build_server_id
    assert_not_nil pending_size_calculation.build_assigned_at
  end
end
