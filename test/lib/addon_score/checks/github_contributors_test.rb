# frozen_string_literal: true

require 'test_helper'

class GithubContributorsTest < ActiveSupport::TestCase
  test '#name' do
    check = create_check
    assert_equal :github_contributors, check.name
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
    check = create_check(valid_github_repo?: false, github_contributors_count: 2)
    assert_equal 0, check.value, '0 value if repo is not valid'

    check = create_check(valid_github_repo?: true, github_contributors_count: 2)
    assert_equal 1, check.value

    check = create_check(valid_github_repo?: true, github_contributors_count: 1)
    assert_equal 0, check.value, '0 value if contributors is not > 1'
  end

  test '#explanation' do
    check = create_check(valid_github_repo?: false, github_contributors_count: 2)
    assert_equal 'Does NOT have more than one contributor on GitHub or does not have a valid Github repository set in `package.json`', check.explanation

    check = create_check(valid_github_repo?: true, github_contributors_count: 2)
    assert_equal 'Has more than one contributor on GitHub', check.explanation
  end

  private

  def create_check(props = {})
    stub_addon = OpenStruct.new(props)
    AddonScore::Checks::GithubContributors.new(stub_addon)
  end
end
