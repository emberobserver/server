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
        'package' => {
          'name' => 'ember-try',
          'date' => ember_try_date
        }
      },
      {
        'package' => {
          'name' => 'my-new-addon',
          'date' => Time.zone.now.utc.iso8601
        }
      },
      {
        'package' => {
          'name' => '@ember/test-helpers',
          'date' => 1.day.ago.utc.iso8601
        }
      },
      {
        'package' => {
          'name' => 'ember-power-select',
          'date' => 4.days.ago.utc.iso8601
        }
      }
    ]

    results = AddonsUpdater.addons_in_need_of_update(matching_npm_packages, 11).map { |a| a[:name] }

    assert_equal(%w[
                   my-new-addon
                   @ember/test-helpers
                 ], results, 'Includes addons that have been updated or are new')
  end

  test 'self.addons_in_need_of_update with a portion of addons scheduled' do
    ember_try_date = 1.day.ago.utc.iso8601
    create(:addon, id: 3, name: 'ember-try', latest_version_date: ember_try_date)
    create(:addon, id: 6, name: '@ember/test-helpers', latest_version_date: 2.days.ago.iso8601)
    create(:addon, id: 15, name: 'ember-power-select', latest_version_date: 3.days.ago.utc.iso8601)
    matching_npm_packages = [
      {
        'package' => {
          'name' => 'ember-try',
          'date' => ember_try_date
        }
      },
      {
        'package' => {
          'name' => 'my-new-addon',
          'date' => Time.zone.now.utc.iso8601
        }
      },
      {
        'package' => {
          'name' => '@ember/test-helpers',
          'date' => 7.days.ago.utc.iso8601
        }
      },
      {
        'package' => {
          'name' => 'ember-power-select',
          'date' => 4.days.ago.utc.iso8601
        }
      }
    ]

    results = AddonsUpdater.addons_in_need_of_update(matching_npm_packages, 15).map { |a| a[:name] }

    assert_equal(%w[
                   ember-try
                   my-new-addon
                   ember-power-select
                 ], results, 'Includes addons that have been updated or are new and those scheduled to be updated')
  end

  test 'self.scheduled_to_be_updated?' do
    hours = [*0...24]
    ids = [*0...100]

    results = hours.map do |h|
      ids.map do |id|
        if AddonsUpdater.scheduled_to_be_updated?(id, h)
          id
        end
      end.compact
    end

    results.each do |r|
      assert(r.length.between?(8, 9))
    end

    assert_equal(200, results.flatten.length, 'Addons updated twice in a day')
  end
end
