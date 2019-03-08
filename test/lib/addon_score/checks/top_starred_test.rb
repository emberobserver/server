# frozen_string_literal: true

require 'test_helper'

class TopStarredTest < ActiveSupport::TestCase
  test '#name' do
    check = create_check
    assert_equal :is_top_starred, check.name
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
    check = create_check(valid_github_repo?: false, is_top_starred: true)
    assert_equal 0, check.value, '0 value if repo is not valid'

    check = create_check(valid_github_repo?: true, is_top_starred: true)
    assert_equal 1, check.value

    check = create_check(valid_github_repo?: true, is_top_starred: false)
    assert_equal 0, check.value, '0 value if not top starred'
  end

  test '#explanation' do
    check = create_check(valid_github_repo?: false, is_top_starred: true)
    assert_equal 'Does not have a GitHub star count in the top 10% of all addons', check.explanation

    check = create_check(valid_github_repo?: true, is_top_starred: true)
    assert_equal 'Has a GitHub star count in the top 10% of all addons', check.explanation
  end

  private

  def create_check(props = {})
    stub_addon = OpenStruct.new(props)
    AddonScore::Checks::TopStarred.new(stub_addon)
  end
end
