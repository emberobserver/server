# frozen_string_literal: true

require 'test_helper'

class HasReadmeTest < ActiveSupport::TestCase
  test '#name' do
    check = create_check
    assert_equal :has_readme, check.name
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
    check = create_check(has_readme: 0)
    assert_equal 0, check.value

    check = create_check(has_readme: 1)
    assert_equal 1, check.value
  end

  test '#explanation' do
    check = create_check(has_readme: 0)
    assert_equal 'Does not have the README filled out', check.explanation

    check = create_check(has_readme: 1)
    assert_equal 'Awarded manually for having the README filled out', check.explanation
  end

  private

  def create_check(props = {})
    stub_addon = OpenStruct.new(props)
    AddonScore::Checks::HasReadme.new(stub_addon)
  end
end
