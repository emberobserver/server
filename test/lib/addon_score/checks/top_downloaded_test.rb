# frozen_string_literal: true

require 'test_helper'

class TopDownloadedTest < ActiveSupport::TestCase
  test '#name' do
    check = create_check
    assert_equal :top_downloaded, check.name
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
    check = create_check(is_top_downloaded: false)
    assert_equal 0, check.value

    check = create_check(is_top_downloaded: true)
    assert_equal 1, check.value
  end

  private

  def create_check(props = {})
    stub_addon = OpenStruct.new(props)
    AddonScore::Checks::TopDownloaded.new(stub_addon)
  end
end
