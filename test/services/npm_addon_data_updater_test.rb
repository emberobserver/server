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
end
