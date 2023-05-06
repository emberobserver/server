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
#  build_type        :string
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

class PendingBuild < ApplicationRecord
  belongs_to :addon_version
  belongs_to :build_server, optional: true

  def self.unassigned
    where('build_assigned_at is null')
  end

  def self.oldest_unassigned
    unassigned.order(created_at: 'asc').first
  end
end
