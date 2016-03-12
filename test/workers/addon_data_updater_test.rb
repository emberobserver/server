require 'test_helper'

class AddonDataUpdaterTest < ActiveSupport::TestCase

  test "addon data updater updates addons from json data" do
    fixture_file_path = File.join(Rails.root, 'test', 'fixtures', 'addons.json')
    addons = ActiveSupport::JSON.decode(File.read(fixture_file_path))

    AddonDataUpdater.new(addons.first).update
    assert_first_addon_data(Addon.find_by_name(addons.first['name']))
  end

  def assert_first_addon_data(addon)
    assert_equal 'a-addon', addon.name
    assert_equal 'https://github.com/a-person/a-addon', addon.repository_url
    assert_equal '1.0.1', addon.latest_version
    assert_equal 'An ember addon that does stuff', addon.description
    assert_equal 'MIT', addon.license
    assert_equal Time.utc(2016, 2, 13, 6, 33, 27).to_s, addon.latest_version_date.to_s
    assert_equal nil, addon.note
    assert_equal false, addon.deprecated
    assert_equal false, addon.official
    assert_equal false, addon.cli_dependency
    assert_equal false, addon.hidden
    assert_equal 'a-person', addon.github_user
    assert_equal 'a-addon', addon.github_repo
    assert_equal Time.utc(2015, 9, 7, 7, 19, 9).to_s, addon.published_date.to_s
    assert_equal 'http://a-person.github.io/a-addon', addon.demo_url
  end

end
