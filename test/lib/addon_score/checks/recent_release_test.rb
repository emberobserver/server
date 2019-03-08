# frozen_string_literal: true

require 'test_helper'

class RecentReleaseTest < ActiveSupport::TestCase
  test '#name' do
    check = create_check
    assert_equal :recent_release, check.name
  end

  test '#max_value' do
    check = create_check
    assert_equal 1, check.max_value
  end

  test '#weight' do
    check = create_check
    assert_equal 1, check.weight
  end

  test '#value' do
    check = create_check(recently_released?: true)
    assert_equal 1, check.value

    check = create_check(recently_released?: false)
    assert_equal 0, check.value
  end

  test '#explanation' do
    check = create_check(recently_released?: true)
    assert_equal 'Has published a release on `npm` within the past three months', check.explanation

    check = create_check(recently_released?: false)
    assert_equal 'Has not published a release to `npm` within the past three months', check.explanation
  end

  private

  def create_check(props = {})
    stub_addon = OpenStruct.new(props)
    AddonScore::Checks::RecentRelease.new(stub_addon)
  end
end
