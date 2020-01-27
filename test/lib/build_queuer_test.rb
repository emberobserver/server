# frozen_string_literal: true

require 'test_helper'

class BuildQueuerTest < ActiveSupport::TestCase
  test 'when addon version has ember_version_compatibility, saves it as semver_string' do
    addon_version = create(:addon_version_with_ember_version_compatibility, ember_version_compatibility: '>= 3.0')

    create_queuer(addon_version).queue

    assert_equal '>= 3.0', PendingBuild.last.semver_string
  end

  test 'when addon version does not have ember_version_compatibility, default value is saved as semver_string' do
    addon_version = create(:addon_version)

    create_queuer(addon_version).queue

    assert_equal BuildQueuer::DEFAULT_EMBER_VERSION_COMPATIBILITY_STRING, PendingBuild.last.semver_string
  end

  private

  def create_queuer(addon_version)
    BuildQueuer.new(addon_version)
  end
end
