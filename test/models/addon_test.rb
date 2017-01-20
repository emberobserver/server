# == Schema Information
#
# Table name: addons
#
#  id                      :integer          not null, primary key
#  name                    :string
#  repository_url          :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  latest_version          :string
#  description             :string
#  license                 :string
#  npm_author_id           :integer
#  latest_version_date     :datetime
#  deprecated              :boolean          default(FALSE)
#  note                    :text
#  official                :boolean          default(FALSE)
#  cli_dependency          :boolean          default(FALSE)
#  hidden                  :boolean          default(FALSE)
#  github_user             :string
#  github_repo             :string
#  has_invalid_github_repo :boolean          default(FALSE)
#  rendered_note           :text
#  last_month_downloads    :integer
#  is_top_downloaded       :boolean          default(FALSE)
#  is_top_starred          :boolean          default(FALSE)
#  score                   :integer
#  published_date          :datetime
#  last_seen_in_npm        :datetime
#  is_wip                  :boolean
#  demo_url                :string
#  ranking                 :integer
#

require 'test_helper'

class AddonTest < ActiveSupport::TestCase

  # Addons hasMany AddonVersions
  # AddonVersion hasOne Review
  # Review belongsTo AddonVersion
  #
  # I need the Addons who’s latest version doesn’t have a review

  # addon has one version with a review - not in result
  # addon has one version with no review - in result

  # addon has two versions with no reviews - latest in result
  # addon has two versions with reviews - not in result

  # addon has two versions and latest has no review - in result
  # addon has two versions and earliest has no review - in result

  test "can find addons whose latest version does not have a review" do
    addon1 = create :addon, name: 'addon1' # one version, with review - not in result
    addon1_v1 = create :addon_version, :with_review, addon: addon1

    addon2 = create :addon, name: 'addon2' # one version, no review - in result
    addon2_v1 = create :addon_version, addon: addon2

    addon3 = create :addon, name: 'addon3' # two versions, latest has no review - in result
    addon3_v1 = create :addon_version, :with_review, addon: addon3
    addon3_v2 = create :addon_version, addon: addon3

    addon4 = create :addon, name: 'addon4' # two versions, latest has review - not in result
    addon4_v1 = create :addon_version, addon: addon4
    addon4_v2 = create :addon_version, :with_review, addon: addon4

    addons = Addon.latest_version_not_reviewed.to_a
    assert_equal [addon2, addon3], addons
  end

  test "oldest_version returns the earliest addon version" do
    addon = create :addon

    v1 = create :addon_version, addon: addon
    v2 = create :addon_version, addon: addon
    v3 = create :addon_version, addon: addon

    assert_equal v1, addon.oldest_version
  end

  test "newest_version returns the most recent addon version" do
    addon = create :addon

    v1 = create :addon_version, addon: addon
    v2 = create :addon_version, addon: addon
    v3 = create :addon_version, addon: addon

    assert_equal v3, addon.newest_version
  end

  test "newest_review returns most recent addon version with a review" do
    addon = create :addon

    v1 = create :addon_version, :with_review, addon: addon
    v2 = create :addon_version, :with_review, addon: addon
    v3 = create :addon_version, addon: addon

    assert_equal v2.review, addon.newest_review
  end

  test "newest_review returns nil if no addon versions have a review" do
    addon = create :addon

    v1 = create :addon_version, addon: addon
    assert_nil addon.newest_review
  end

  test "is recently_released if newest version released less than 3 months ago" do
    addon = create :addon, latest_version: '1.2.3'
    create :addon_version, addon: addon, released: 2.months.ago

    assert addon.recently_released?
  end

  test "not recently_released if newest version released over 3 months ago" do
    addon = create :addon, latest_version: '1.2.3'
    create :addon_version, addon: addon, released: 4.months.ago

    assert !addon.recently_released?
  end

  test "not recently released if no latest version" do
    addon = build :addon, latest_version: nil

    assert !addon.recently_released?
  end

  test "recently committed to if penultimate commit date less than 3 months ago" do
    stats = build :github_stats, penultimate_commit_date: 2.months.ago
    addon = build :addon, github_stats: stats

    assert addon.recently_committed_to?
  end

  test "not recently committed to if no github stats" do
    addon = build :addon, github_stats: nil

    assert !addon.recently_committed_to?
  end

  test "not recently committed to if no penultimate commit date" do
    stats = build :github_stats, penultimate_commit_date: nil
    addon = build :addon, github_stats: stats

    assert !addon.recently_committed_to?
  end

  test "not recently committed to if penultimate commit date over 3 months ago" do
    stats = build :github_stats, penultimate_commit_date: 4.months.ago
    addon = build :addon, github_stats: stats

    assert !addon.recently_committed_to?
  end

  test "query for active addons returns those that are not hidden and not wip" do
    create :addon, hidden: true
    create :addon, is_wip: true

    active = create :addon, hidden: false, is_wip: false
    also_active = create :addon, hidden: nil, is_wip: nil

    assert_equal [active, also_active], Addon.active.to_a
  end

  test "top_scoring returns addons with score above 7" do
    create :addon, score: 1
    create :addon, score: 7

    top = create :addon, score: 8
    also_top = create :addon, score: 10

    assert_equal [top, also_top], Addon.top_scoring.to_a
  end

  test "top_scoring excludes addons marked as deprecated" do
    top = create(:addon, score: 8)
    top_but_deprecated = create(:addon, score: 10, deprecated: true)

    assert_equal [top], Addon.top_scoring.to_a
  end
end
