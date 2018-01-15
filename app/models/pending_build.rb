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

class PendingBuild < ApplicationRecord
  belongs_to :addon_version
  belongs_to :build_server

  def self.unassigned
    where('build_assigned_at is null')
  end

  def self.oldest_unassigned
    unassigned.order(created_at: 'asc').first
  end
end
