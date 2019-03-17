# frozen_string_literal: true

require 'test_helper'

class RecentReleaseTest < ActiveSupport::TestCase
  test '#name' do
    check = create_check
    assert_equal :recent_release, check.name
  end

  test '#max_value' do
    check = create_check
    assert_equal 100, check.max_value
  end

  test '#weight' do
    check = create_check
    assert_equal 1, check.weight
  end

  test '#value' do
    check = create_check(latest_addon_version: OpenStruct.new(released: 89.days.ago))
    assert_equal 100, check.value

    check = create_check(latest_addon_version: OpenStruct.new(released: 4.months.ago))
    assert_equal 80, check.value

    check = create_check(latest_addon_version: OpenStruct.new(released: 7.months.ago))
    assert_equal 50, check.value

    check = create_check(latest_addon_version: OpenStruct.new(released: 13.months.ago))
    assert_equal 0, check.value
  end

  test '#explanation' do
    check = create_check(latest_addon_version: OpenStruct.new(released: 13.months.ago))
    assert_equal 'Has not published a release to `npm` tagged `latest` within the past year', check.explanation

    check = create_check(latest_addon_version: OpenStruct.new(released: 1.day.ago))
    assert_equal 'Published a release to `npm` tagged `latest` within the past 3 months', check.explanation

    check = create_check(latest_addon_version: OpenStruct.new(released: 4.months.ago))
    assert_equal 'Published a release to `npm` tagged `latest` within the past 6 months', check.explanation

    check = create_check(latest_addon_version: OpenStruct.new(released: 7.months.ago))
    assert_equal 'Published a release to `npm` tagged `latest` within the past year', check.explanation
  end

  private

  def create_check(props = {})
    stub_addon = OpenStruct.new(props)
    AddonScore::Checks::RecentRelease.new(stub_addon)
  end
end
