# frozen_string_literal: true

require 'test_helper'

class BuildQueueControllerTest < ControllerTest
  include BuildServerAuthHelper

  test "responds with HTTP unauthorized when request doesn't include a token" do
    post :get_build

    assert_response :unauthorized
  end

  test 'responds with HTTP 204 (no content) when no builds are in the queue' do
    authed_post :get_build

    assert_response :no_content
  end

  test 'responds with HTTP 204 (no content) when the queue is not empty but all builds are assigned' do
    addon_version = create(:addon_version)
    other_build_server = create(:build_server)
    x = create(:pending_build, addon_version: addon_version, build_server: other_build_server, build_assigned_at: 1.hour.ago)

    authed_post :get_build

    assert_response :no_content
  end

  test 'responds with build info for the oldest non-assigned build when queue is not empty' do
    addon = create(:addon, repository_url: 'file:///')
    oldest_addon_version, middle_addon_version, newest_addon_version = create_list(:addon_version, 3, addon: addon)

    create :pending_build, addon_version: oldest_addon_version, created_at: 2.months.ago, build_server: create(:build_server), build_assigned_at: 2.months.ago
    create :pending_build, addon_version: middle_addon_version, created_at: 1.month.ago
    create :pending_build, addon_version: newest_addon_version, created_at: 1.hour.ago

    authed_post :get_build

    assert_response :success
    assert_equal addon.name, json_response['pending_build']['addon_name']
    assert_equal 'file:///', json_response['pending_build']['repository_url']
    assert_equal middle_addon_version.version, json_response['pending_build']['version']
  end

  test 'sets the build server and assigned date when a build is requested' do
    addon_version = create(:addon_version)
    pending_build = create(:pending_build, addon_version: addon_version)

    authed_post :get_build

    pending_build.reload

    assert_equal build_server.id, pending_build.build_server_id
    assert_not_nil pending_build.build_assigned_at
  end

  test 'returns the assigned build for a token that already has a build assigned' do
    addon_version = create(:addon_version)
    pending_build = create(:pending_build, addon_version: addon_version, build_server: build_server, build_assigned_at: 1.day.ago)

    authed_post :get_build

    assert_response :success
    assert_equal build_server.id, pending_build.build_server_id
    assert_not_nil pending_build.build_assigned_at
  end

  test "includes the 'canary' flag in the response" do
    addon_version = create(:addon_version)
    pending_build = create(:pending_build, addon_version: addon_version, canary: true)

    authed_post :get_build

    assert_equal true, json_response['pending_build']['canary']
  end

  test "includes the build's semver string as ember_version_compatibility" do
    ember_version_compatibility_string = '>= 3.16.0'
    addon_version = create(:addon_version)
    pending_build = create(:pending_build, addon_version: addon_version, semver_string: ember_version_compatibility_string)

    authed_post :get_build

    assert_equal ember_version_compatibility_string, json_response['pending_build']['ember_version_compatibility']
  end
end
