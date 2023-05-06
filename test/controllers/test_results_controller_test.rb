# frozen_string_literal: true

require 'test_helper'

class TestResultsControllerTest < ControllerTest
  setup :create_pending_build

  test 'responds with HTTP unauthorized if request does not include token' do
    post :create

    assert_response :unauthorized
  end

  test 'responds with HTTP forbidden if the build was for a different build server' do
    other_build_server = create(:build_server)
    other_pending_build = create(:pending_build, addon_version: create(:addon_version), build_server: other_build_server)

    authed_post :create, pending_build_id: other_pending_build.id

    assert_response :forbidden
  end

  test 'responds with HTTP 404 when build does not exist' do
    authed_post :create, pending_build_id: 'foo'

    assert_response :not_found
  end

  test 'responds with HTTP 422 (unprocessable entity) when status is missing' do
    authed_post :create, pending_build_id: @pending_build.id, results: build_test_result_string(1)

    assert_response :unprocessable_entity
  end

  test "does not require a 'results' param when status is 'failed'" do
    authed_post :create, pending_build_id: @pending_build.id, status: 'failed', status_message: 'missing Git tag'

    assert_response :ok
  end

  test "requires a status message when status is 'failed'" do
    authed_post :create, pending_build_id: @pending_build.id, status: 'failed'

    assert_response :unprocessable_entity
  end

  test 'records the correct information when a failed build is reported' do
    authed_post :create, pending_build_id: @pending_build.id, status: 'failed', status_message: 'missing Git tag'

    test_result = TestResult.find_by(addon_version_id: @pending_build.addon_version.id)
    assert_equal false, test_result.succeeded?
    assert_equal 'missing Git tag', test_result.status_message
  end

  test 'records the correct information when a successful build is reported' do
    authed_post :create, pending_build_id: @pending_build.id, status: 'succeeded', results: build_test_result_string(2)

    test_result = TestResult.find_by(addon_version_id: @pending_build.addon_version.id)
    assert_equal true, test_result.succeeded?
  end

  test 'responds with HTTP 422 (unprocessable entity) when results is not a valid JSON string' do
    authed_post :create, pending_build_id: @pending_build.id, status: 'succeeded', results: 'foobar'

    assert_response :unprocessable_entity
  end

  test "responds with HTTP 422 (unprocessable entity) when results don't include any scenarios" do
    authed_post :create, pending_build_id: @pending_build.id, status: 'succeeded', results: build_test_result_string(0)

    assert_response :unprocessable_entity
  end

  test 'reporting results removes the build from the queue' do
    assert_difference 'PendingBuild.count', -1 do
      authed_post :create, pending_build_id: @pending_build.id, status: 'succeeded', results: build_test_result_string(1)
    end
  end

  test 'reporting results adds the results to the DB' do
    test_result_str = build_test_result_string(2)

    assert_difference 'TestResult.count' do
      authed_post :create, pending_build_id: @pending_build.id, status: 'succeeded', results: test_result_str
    end
  end

  test 'reporting results creates EmberVersionCompatibilities for each version' do
    test_result_str = build_test_result_string(2)

    assert_difference 'EmberVersionCompatibility.count', 2 do
      authed_post :create, pending_build_id: @pending_build.id, status: 'succeeded', results: test_result_str
    end
  end

  test "sets 'build_type' field on TestResult to value from PendingBuild" do
    @pending_build.update(build_type: :canary)

    authed_post :create, pending_build_id: @pending_build.id, status: 'succeeded', results: build_test_result_string(1)

    test_result = TestResult.find_by(addon_version_id: @pending_build.addon_version.id)
    assert_equal 'canary', test_result.build_type
  end

  test 'saves build server ID with record result' do
    authed_post :create, pending_build_id: @pending_build.id, status: 'succeeded', results: build_test_result_string(1)

    assert_equal build_server, TestResult.find_by(addon_version_id: @pending_build.addon_version_id).build_server
  end

  test 'saves the version compatibility string that was used, when there is one' do
    addon_version = create(:addon_version_with_ember_version_compatibility, ember_version_compatibility: '>= 2.0.0')
    pending_build = create(:pending_build, addon_version: addon_version, build_server: build_server, build_assigned_at: 5.minutes.ago)
    authed_post :create, pending_build_id: pending_build.id, status: 'succeeded', results: build_test_result_string(1)

    assert_equal '>= 2.0.0', TestResult.find_by(addon_version_id: pending_build.addon_version_id).semver_string
  end

  test "does not save a semver string when there isn't one" do
    authed_post :create, pending_build_id: @pending_build.id, status: 'succeeded', results: build_test_result_string(1)

    assert_nil TestResult.find_by(addon_version_id: @pending_build.addon_version_id).semver_string
  end

  test 'does not save semver string for canary builds' do
    addon_version = create(:addon_version_with_ember_version_compatibility, ember_version_compatibility: '>= 2.0.0')
    pending_build = create(:pending_build, :canary, addon_version: addon_version, build_server: build_server, build_assigned_at: 5.minutes.ago)
    authed_post :create, pending_build_id: pending_build.id, status: 'succeeded', results: build_test_result_string(1)

    assert_nil TestResult.find_by(addon_version_id: pending_build.addon_version_id).semver_string
  end

  test "captures provided 'output' file when 'format' is missing" do
    output_file = fixture_file_upload('build.output', 'text/plain')
    authed_post :create, pending_build_id: @pending_build.id, status: 'succeeded', results: build_test_result_string(1), output: output_file

    test_result = TestResult.find_by(addon_version_id: @pending_build.addon_version_id)
    assert_equal 'This is the output', test_result.output.chomp
  end

  test "captures provided output from param when 'format' is 'json'" do
    output = { foo: 'bar' }.to_json
    authed_post :create, pending_build_id: @pending_build.id, format: 'json', status: 'succeeded', results: build_test_result_string(1), output: output

    test_result = TestResult.find_by(addon_version_id: @pending_build.addon_version_id)
    assert_equal '{"foo":"bar"}', test_result.output.chomp
  end

  test "output format defaults to 'text' when not provided" do
    authed_post :create, pending_build_id: @pending_build.id, status: 'failed', status_message: 'unknown'

    test_result = TestResult.find_by(addon_version_id: @pending_build.addon_version_id)
    assert_equal 'text', test_result.output_format
  end

  test "saves value for 'format' param" do
    output = { foo: 'bar' }.to_json
    authed_post :create, pending_build_id: @pending_build.id, format: 'json', status: 'succeeded', results: build_test_result_string(1), output: output

    test_result = TestResult.find_by(addon_version_id: @pending_build.addon_version_id)
    assert_equal 'json', test_result.output_format
  end

  test 'saves provided results' do
    output = { foo: 'bar' }.to_json
    ember_try_results = build_test_result_string(7)
    authed_post :create, pending_build_id: @pending_build.id, format: 'json', status: 'succeeded', results: ember_try_results, output: output

    test_result = TestResult.find_by(addon_version_id: @pending_build.addon_version_id)
    assert_equal 7, test_result.ember_try_results['scenarios'].count
  end

  test "'retry' action responds with HTTP unauthorized if request is not authenticated" do
    test_result = create(:test_result)

    post :retry, params: { id: test_result.id }

    assert_response :unauthorized
  end

  test "'retry' action responds with HTTP 404 if test result is invalid" do
    user = create(:user)

    post_as_user user, :retry, id: 42

    assert_response :not_found
  end

  test "'retry' action enqueues a new pending build with same parameters" do
    user = create(:user)
    addon_version = create(:addon_version)
    test_result = create(:test_result, :canary, addon_version: addon_version)

    assert_difference 'PendingBuild.count' do
      post_as_user user, :retry, id: test_result.id
    end

    assert_response :created

    new_build = PendingBuild.last
    assert_equal addon_version.id, new_build.addon_version_id, 'new build is created for same addon version'
    assert_equal test_result.build_type, new_build.build_type, 'new build is created with same value for "build_type" attribute'
  end

  private

  def create_pending_build
    addon_version = create(:addon_version)
    @pending_build = create(:pending_build, addon_version: addon_version, build_server: build_server, build_assigned_at: 5.minutes.ago)
  end

  def build_server
    @build_server ||= create(:build_server)
  end

  def build_test_result_string(num_scenarios)
    scenarios = Array.new(num_scenarios) { |i| build_scenario(i) }
    { scenarios: scenarios }.to_json
  end

  def build_scenario(i)
    {
      scenarioName: "ember-3.#{i}",
      passed: true,
      allowedToFail: false,
      dependencies: [
        {
          name: 'ember-source',
          versionSeen: "3.#{i}.2",
          versionExpected: "~3.#{i}.0",
          type: 'yarn'
        }
      ]
    }
  end

  def authed_post(action, data = nil)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(build_server.token)
    post action, params: data
  end
end
