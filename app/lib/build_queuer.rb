# frozen_string_literal: true

class BuildQueuer
  DEFAULT_EMBER_VERSION_COMPATIBILITY_STRING = '~3.4.0 || ~3.8.0 || ~3.12.0 || >=3.13.0'

  attr_reader :addon_version

  def initialize(addon_version)
    @addon_version = addon_version
  end

  def queue
    PendingBuild.create!(
      addon_version: addon_version,
      semver_string: addon_version.ember_version_compatibility || DEFAULT_EMBER_VERSION_COMPATIBILITY_STRING
    )
  end
end
