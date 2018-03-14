# frozen_string_literal: true

require 'test_helper'

class AddonsUpdaterTest < ActiveSupport::TestCase
  test 'self.addons_in_need_of_update' do
    ember_try_date = 1.day.ago.utc.iso8601
    create(:addon, name: 'ember-try', latest_version_date: ember_try_date)
    create(:addon, name: '@ember/test-helpers', latest_version_date: 2.days.ago.iso8601)
    create(:addon, name: 'ember-power-select', latest_version_date: 3.days.ago.utc.iso8601)
    matching_npm_packages = [
      {
        "package": {
          "name": "ember-try",
          "date": ember_try_date
        }
      },
      {
        "package": {
          "name": "my-new-addon",
          "date": DateTime.now.utc.iso8601
        }
      },
      {
        "package": {
          "name": "@ember/test-helpers",
          "date": 1.day.ago.utc.iso8601
        }
      },
      {
        "package": {
          "name": "ember-power-select",
          "date": 4.days.ago.utc.iso8601
        }
      }
    ]

    results = AddonsUpdater.addons_in_need_of_update(matching_npm_packages)

    assert_equal(%w(
      my-new-addon
      @ember/test-helpers
    ), results, "Includes addons that have been updated or are new")
  end
end
