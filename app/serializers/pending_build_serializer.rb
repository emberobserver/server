# frozen_string_literal: true

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
# Indexes
#
#  index_pending_builds_on_addon_version_id  (addon_version_id)
#  index_pending_builds_on_build_server_id   (build_server_id)
#
# Foreign Keys
#
#  fk_rails_...  (addon_version_id => addon_versions.id)
#  fk_rails_...  (build_server_id => build_servers.id)
#

class PendingBuildSerializer < ApplicationSerializer
  DEFAULT_EMBER_VERSION_COMPATIBILITY_STRING = '~3.28.0 || ~4.4.0 || >=4.5.0'

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
