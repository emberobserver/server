# frozen_string_literal: true

require 'test_helper'

class AddonDependencyDataBackfillTest < ActiveSupport::TestCase
  test 'self.updates_package_addon_ids' do
    foo_addon = create(:addon, name: 'foo-addon')
    bar_addon = create(:addon, name: 'bar-addon')

    addon1 = create(:addon, name: 'ember-try', latest_version_date: 1.day.ago.iso8601)
    addon1_older_version = create(:addon_version, addon: addon1)
    create(:addon_version_dependency, package: 'foo-addon', dependency_type: 'devDependency', addon_version: addon1_older_version)
    create(:addon_version_dependency, package: 'bar-addon', dependency_type: 'dependency', addon_version: addon1_older_version)
    create(:addon_version_dependency, package: 'not-an-addon', dependency_type: 'dependency', addon_version: addon1_older_version)

    addon1_latest_version = create(:addon_version, addon: addon1)
    create(:addon_version_dependency, package: 'foo-addon', dependency_type: 'devDependency', addon_version: addon1_latest_version)
    create(:addon_version_dependency, package: 'not-an-addon', dependency_type: 'dependency', addon_version: addon1_latest_version)

    addon1.latest_addon_version = addon1_latest_version
    addon1.save!

    addon2 = create(:addon, name: '@ember/other', latest_version_date: 2.days.ago.iso8601)
    addon2_latest_version = create(:addon_version, addon: addon2)
    create(:addon_version_dependency, package: 'foo-addon', dependency_type: 'devDependency', addon_version: addon2_latest_version)
    create(:addon_version_dependency, package: 'bar-addon', dependency_type: 'dependency', addon_version: addon2_latest_version)
    create(:addon_version_dependency, package: 'not-an-addon', dependency_type: 'dependency', addon_version: addon2_latest_version)
    addon2.latest_addon_version = addon2_latest_version
    addon2.save!

    PackageAddonUpdater.run

    addon1_older_version.reload
    addon1_latest_version.reload
    addon2_latest_version.reload

    addon1_older_version.all_dependencies.each do |d|
      assert_nil d.package_addon_id, 'Older addon version dependencies should not be updated'
    end

    assert_equal foo_addon.id, find_dependency(addon1_latest_version, 'foo-addon').package_addon_id
    assert_nil find_dependency(addon1_latest_version, 'not-an-addon').package_addon_id

    assert_equal foo_addon.id, find_dependency(addon2_latest_version, 'foo-addon').package_addon_id
    assert_equal bar_addon.id, find_dependency(addon2_latest_version, 'bar-addon').package_addon_id
    assert_nil find_dependency(addon2_latest_version, 'not-an-addon').package_addon_id
  end

  private

  def find_dependency(addon_version, package_name)
    addon_version.all_dependencies.find { |d| d.package == package_name }
  end
end
