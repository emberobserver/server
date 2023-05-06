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

require 'test_helper'

class PendingBuildTest < ActiveSupport::TestCase
  test 'PendingBuild.unassigned returns only unassigned builds' do
    create_list(:build_server, 2).each do |build_server|
      addon_version = create(:addon_version)
      create(:pending_build, addon_version: addon_version, build_server: build_server, build_assigned_at: 1.hour.ago)
    end
    create_list(:addon_version, 3).each do |addon_version|
      create(:pending_build, addon_version: addon_version)
    end

    assert_equal 3, PendingBuild.unassigned.count
  end

  test 'PendingBuild.oldest_unassigned returns the oldest unassigned build' do
    addon = create(:addon)
    old_but_assigned_addon_version = create(:addon_version, addon: addon, version: '1.0.0')
    old_addon_version = create(:addon_version, addon: addon, version: '1.5.0')
    new_addon_version = create(:addon_version, addon: addon, version: '2.0.0')

    create(:pending_build, addon_version: old_but_assigned_addon_version, created_at: 2.months.ago, build_assigned_at: 2.months.ago)
    create(:pending_build, addon_version: old_addon_version, created_at: 1.month.ago)
    create(:pending_build, addon_version: new_addon_version, created_at: 1.day.ago)

    assert_equal '1.5.0', PendingBuild.oldest_unassigned.addon_version.version
  end
end
