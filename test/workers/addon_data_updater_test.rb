# frozen_string_literal: true

require 'test_helper'

class AddonDataUpdaterTest < ActiveSupport::TestCase
  setup do
    fixture_file_path = File.join(Rails.root, 'test', 'fixtures', 'addons.json')
    @addon_data = ActiveSupport::JSON.decode(File.read(fixture_file_path))
  end

  test 'addon data updater creates addons from json data' do
    AddonDataUpdater.new(@addon_data.first).update
    assert_first_addon_data(Addon.find_by(name: @addon_data.first['name']))
  end

  test 'addon data updater updates addons from json data' do
    addon = create(:addon, name: 'a-addon', license: 'BSD')

    AddonDataUpdater.new(@addon_data.first).update
    assert_first_addon_data(addon.reload)
  end

  test 'sets package_info_last_updated_at' do
    addon = create(:addon, name: 'a-addon', package_info_last_updated_at: 10.days.ago)

    AddonDataUpdater.new(@addon_data.first).update
    addon.reload
    assert(addon.package_info_last_updated_at > 1.day.ago, 'package_info_last_updated_at set to nowish')
  end

  def assert_first_addon_data(addon)
    assert_equal 'a-addon', addon.name
    assert_equal 'https://github.com/a-person/a-addon', addon.repository_url
    assert_equal '1.0.1', addon.latest_version
    assert_equal 'An ember addon that does stuff', addon.description
    assert_equal 'MIT', addon.license
    assert_equal Time.utc(2016, 2, 13, 6, 33, 27).to_s, addon.latest_version_date.to_s
    assert_nil addon.note
    assert_equal false, addon.deprecated
    assert_equal false, addon.official
    assert_equal false, addon.cli_dependency
    assert_equal false, addon.hidden
    assert_equal 'a-person', addon.github_user
    assert_equal 'a-addon', addon.github_repo
    assert_equal Time.utc(2015, 9, 7, 7, 19, 9).to_s, addon.published_date.to_s
    assert_equal 'http://a-person.github.io/a-addon', addon.demo_url
    assert_equal 'THIS IS A README', addon.readme.contents
    assert_equal 5, addon.addon_versions.count
    assert_equal addon.latest_addon_version_id, addon.addon_versions.find_by(version: '1.0.1').id
  end
end
