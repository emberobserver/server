# == Schema Information
#
# Table name: pending_builds
#
#  id                :integer          not null, primary key
#  addon_version_id  :integer
#  build_assigned_at :datetime
#  build_server_id   :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  canary            :boolean          default(FALSE), not null
#

DEFAULT_EMBER_VERSION_COMPATIBILITY_STRING='>= 1.12.0'

class PendingBuildSerializer < ApplicationSerializer
  attributes :id, :addon_name, :repository_url, :version, :canary, :ember_version_compatibility

  def addon_name
    object.addon_version.addon_name
  end

  def repository_url
    object.addon_version.addon.repository_url
  end

  def version
    object.addon_version.version
  end

  def ember_version_compatibility
    object.addon_version.ember_version_compatibility || DEFAULT_EMBER_VERSION_COMPATIBILITY_STRING
  end
end
