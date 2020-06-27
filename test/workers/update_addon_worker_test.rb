# frozen_string_literal: true

require 'test_helper'
require 'sidekiq/testing'

class UpdateAddonWorkerTest < ActiveSupport::TestCase
  test 'for addons that are not skipped, fetches data from NPM, updates the database, and scores the addon' do
    fixture_file_path = Rails.root.join('test', 'fixtures', 'registry_response_for_ember-try.json')
    addon_data = JSON.parse(File.read(fixture_file_path))
    addon = create(:addon, name: addon_data['name'])

    PackageFetcher.expects(:run).with(addon.name).returns(addon_data)
    NpmAddonDataUpdater.any_instance.expects(:update).returns(addon)

    assert_difference 'AddonScoreWorker.jobs.size' do
      UpdateAddonWorker.new.perform 'ember-try'
    end
  end

  test 'for addons that exist and are marked as #removed_from_npm, no updating is done' do
    fixture_file_path = Rails.root.join('test', 'fixtures', 'registry_response_for_ember-try.json')
    addon_data = JSON.parse(File.read(fixture_file_path))
    addon = create(:addon, name: addon_data['name'], removed_from_npm: true)

    PackageFetcher.expects(:run).with(addon.name).never
    NpmAddonDataUpdater.any_instance.expects(:update).never

    assert_no_difference 'AddonScoreWorker.jobs.size' do
      UpdateAddonWorker.new.perform 'ember-try'
    end
  end
end