# frozen_string_literal: true

require 'test_helper'

class RecentCommitTest < ActiveSupport::TestCase
  test '#name' do
    check = create_check
    assert_equal :recent_commit, check.name
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
    check = create_check(valid_github_repo?: false, recently_committed_to?: true)
    assert_equal 0, check.value, '0 value if repo is not valid'

    check = create_check(valid_github_repo?: true, recently_committed_to?: true)
    assert_equal 1, check.value

    check = create_check(valid_github_repo?: true, recently_committed_to?: false)
    assert_equal 0, check.value, '0 value if commit is not recent'
  end

  test '#explanation' do
    check = create_check(valid_github_repo?: false, recently_committed_to?: true)
    assert_equal 'Does NOT have more than one commit in the past three months or does not have a valid Github repository set in `package.json`', check.explanation

    check = create_check(valid_github_repo?: true, recently_committed_to?: true)
    assert_equal 'Has more than one commit in the past three months', check.explanation
  end

  private

  def create_check(props = {})
    stub_addon = OpenStruct.new(props)
    AddonScore::Checks::RecentCommit.new(stub_addon)
  end
end
