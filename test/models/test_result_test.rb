# frozen_string_literal: true

# == Schema Information
#
# Table name: test_results
#
#  id                :integer          not null, primary key
#  addon_version_id  :integer
#  succeeded         :boolean
#  status_message    :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  canary            :boolean          default(FALSE), not null
#  build_server_id   :integer
#  semver_string     :string
#  output            :text
#  output_format     :string           default("text"), not null
#  ember_try_results :jsonb
#
# Indexes
#
#  index_test_results_on_addon_version_id  (addon_version_id)
#  index_test_results_on_build_server_id   (build_server_id)
#
# Foreign Keys
#
#  fk_rails_...  (addon_version_id => addon_versions.id)
#  fk_rails_...  (build_server_id => build_servers.id)
#

require 'test_helper'

class TestResultTest < ActiveSupport::TestCase
  test 'only accepts valid values for output_format' do
    addon_version = create(:addon_version)
    build_server = create(:build_server)
    valid_formats = %w[json text]
    some_invalid_formats = %w[binary foo]

    valid_formats.each do |format|
      test_result = TestResult.new(output_format: format, output: '{}', addon_version: addon_version, build_server: build_server)
      assert test_result.valid?
    end

    some_invalid_formats.each do |format|
      test_result = TestResult.new(output_format: format, output: '{}', addon_version: addon_version, build_server: build_server)
      assert !test_result.valid?
    end
  end

  test 'when output_format is "json", output must be valid JSON' do
    invalid_json = "{foo: 'bar' BAZ}"

    addon_version = create(:addon_version)
    build_server = create(:build_server)

    test_result = TestResult.new(
      addon_version: addon_version,
      build_server: build_server,
      output: invalid_json,
      output_format: 'json'
    )

    assert !test_result.valid?
    assert_equal 'must be valid JSON', test_result.errors[:output].first
  end
end
