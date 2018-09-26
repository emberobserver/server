# frozen_string_literal: true

# == Schema Information
#
# Table name: pending_size_calculations
#
#  id                :integer          not null, primary key
#  addon_version_id  :integer
#  build_assigned_at :datetime
#  build_server_id   :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_pending_size_calculations_on_addon_version_id  (addon_version_id)
#  index_pending_size_calculations_on_build_server_id   (build_server_id)
#
# Foreign Keys
#
#  fk_rails_...  (addon_version_id => addon_versions.id)
#  fk_rails_...  (build_server_id => build_servers.id)
#

require 'test_helper'

class PendingSizeCalculationTest < ActiveSupport::TestCase
  test 'PendingSizeCalculation.unassigned returns only unassigned pending calculations' do
    create_list(:build_server, 2).each do |build_server|
      addon_version = create(:addon_version)
      create(:pending_size_calculation, addon_version: addon_version, build_server: build_server, build_assigned_at: 1.hour.ago)
    end
    create_list(:addon_version, 3).each do |addon_version|
      create(:pending_size_calculation, addon_version: addon_version)
    end

    assert_equal 3, PendingSizeCalculation.unassigned.count
  end

  test 'PendingSizeCalculation.oldest_unassigned returns all unassigned pending calculation if no limit' do
    addon = create(:addon)
    oldest_addon_version = create(:addon_version, addon: addon, version: '1.0.0')
    old_addon_version = create(:addon_version, addon: addon, version: '1.5.0')
    new_addon_version = create(:addon_version, addon: addon, version: '2.0.0')

    create(:pending_size_calculation, addon_version: oldest_addon_version, created_at: 2.months.ago)
    create(:pending_size_calculation, addon_version: old_addon_version, created_at: 1.month.ago)
    create(:pending_size_calculation, addon_version: new_addon_version, created_at: 1.day.ago)

    assert_equal 3, PendingSizeCalculation.oldest_unassigned.count
  end

  test 'PendingSizeCalculation.oldest_unassigned returns n unassigned pending calculations if given limit' do
    addon = create(:addon)
    oldest_addon_version = create(:addon_version, addon: addon, version: '1.0.0')
    old_addon_version = create(:addon_version, addon: addon, version: '1.5.0')
    new_addon_version = create(:addon_version, addon: addon, version: '2.0.0')

    create(:pending_size_calculation, addon_version: oldest_addon_version, created_at: 2.months.ago)
    create(:pending_size_calculation, addon_version: old_addon_version, created_at: 1.month.ago)
    create(:pending_size_calculation, addon_version: new_addon_version, created_at: 1.day.ago)

    assert_equal 1, PendingSizeCalculation.oldest_unassigned(1).count
  end

  test 'PendingSizeCalculation.oldest_unassigned returns pending calculations ordered by creation date' do
    addon = create(:addon)
    oldest_addon_version = create(:addon_version, addon: addon, version: '1.0.0')
    old_addon_version = create(:addon_version, addon: addon, version: '1.5.0')
    new_addon_version = create(:addon_version, addon: addon, version: '2.0.0')

    create(:pending_size_calculation, addon_version: oldest_addon_version, created_at: 2.months.ago)
    create(:pending_size_calculation, addon_version: old_addon_version, created_at: 1.month.ago)
    create(:pending_size_calculation, addon_version: new_addon_version, created_at: 1.day.ago)

    results = PendingSizeCalculation.oldest_unassigned

    assert_equal(%w[1.0.0 1.5.0 2.0.0], results.map { |r| r.addon_version.version })
  end
end
