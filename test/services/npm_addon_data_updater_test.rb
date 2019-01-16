# frozen_string_literal: true

require 'test_helper'

class NpmAddonDataUpdaterTest < ActiveSupport::TestCase
  setup do
    fixture_file_path = Rails.root.join('test', 'fixtures', 'addons.json')
    @addon_data = ActiveSupport::JSON.decode(File.read(fixture_file_path))
  end

  test "it sets 'github_user' and 'github_repo' for basic repo URLs" do
    addon_data = @addon_data.first
    addon_data['repository']['url'] = 'https://github.com/foo/bar'

    updater = NpmAddonDataUpdater.new(addon_data)
    addon = updater.update

    assert_equal 'foo', addon.github_user
    assert_equal 'bar', addon.github_repo
  end

  test "it sets 'github_user' and 'github_repo' for monorepo URLs" do
    addon_data = @addon_data.first
    addon_data['repository']['url'] = 'https://github.com/foo/bar/tree/master/packages/baz'

    updater = NpmAddonDataUpdater.new(addon_data)
    addon = updater.update

    assert_equal 'foo', addon.github_user
    assert_equal 'bar', addon.github_repo
  end

  test "it sets 'github_user' and 'github_repo' for repo URLs ending in .git" do
    addon_data = @addon_data.first
    addon_data['repository']['url'] = 'https://github.com/foo/bar.git'

    updater = NpmAddonDataUpdater.new(addon_data)
    addon = updater.update

    assert_equal 'foo', addon.github_user
    assert_equal 'bar', addon.github_repo
  end

  test "it sets the package addon id on the version dependency" do
    broccoli_addon = Addon.create(name: 'broccoli-asset-rev')
    ember_try_addon = Addon.create(name: 'ember-try')

    addon_data = @addon_data.first
    updater = NpmAddonDataUpdater.new(addon_data)
    addon = updater.update

    dependencies = addon.latest_addon_version.all_dependencies
    broccoli_dep = dependencies.find { |dep| dep.package == 'broccoli-asset-rev' }
    ember_try_dep = dependencies.find { |dep| dep.package == 'ember-try' }
    ember_cli_dep = dependencies.find { |dep| dep.package == 'ember-cli' }

    assert_equal broccoli_addon.id, broccoli_dep.package_addon_id, 'Package addon references the right addon'
    assert_equal ember_try_addon.id, ember_try_dep.package_addon_id, 'Package addon references the right addon'
    assert_nil ember_cli_dep.package_addon_id, 'Package addon is not set if dependency does not reference an existing addon'
  end
end
