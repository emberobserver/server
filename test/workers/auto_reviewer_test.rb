# frozen_string_literal: true

require 'test_helper'

class AddonDataUpdaterTest < ActiveSupport::TestCase
  test 'updates addons with all-yes reviews' do
    addon = create(:addon)
    addon_version = create(:addon_version, addon: addon, released: 2.weeks.ago)
    create(
      :review,
      addon_version: addon_version,
      has_tests: 1,
      has_readme: 1,
      is_more_than_empty_addon: 1,
      is_open_source: 1,
      has_build: 1
    )
    newest_version = create(:addon_version, addon: addon, released: 1.week.ago)
    addon.update_attributes(latest_addon_version: newest_version)

    assert_difference 'Review.count', 1 do
      AutoReviewer.rereview_addons
    end
  end

  test "does not update addons that don't have all-yes reviews" do
    addon = create(:addon)
    addon_version = create(:addon_version, addon: addon, released: 2.weeks.ago)
    create(
      :review,
      addon_version: addon_version,
      has_tests: 1,
      has_readme: 1,
      is_more_than_empty_addon: 1,
      is_open_source: 1,
      has_build: 0
    )
    newest_version = create(:addon_version, addon: addon, released: 1.week.ago)
    addon.update_attributes(latest_addon_version: newest_version)

    assert_no_difference 'Review.count' do
      AutoReviewer.rereview_addons
    end
  end

  test 'preserves note in reviews' do
    addon = create(:addon)
    addon_version = create(:addon_version, addon: addon, released: 2.weeks.ago)
    create(
      :review,
      addon_version: addon_version,
      has_tests: 1,
      has_readme: 1,
      is_more_than_empty_addon: 1,
      is_open_source: 1,
      has_build: 1,
      review: 'Lorem ipsum'
    )
    newest_version = create(:addon_version, addon: addon, released: 1.week.ago)
    addon.update_attributes(latest_addon_version: newest_version)

    AutoReviewer.rereview_addons

    assert_equal 'Lorem ipsum', newest_version.review.review
  end
end
