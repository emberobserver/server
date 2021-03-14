# frozen_string_literal: true
# == Schema Information
#
# Table name: addons
#
#  id                           :integer          not null, primary key
#  name                         :string
#  repository_url               :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  latest_version               :string
#  description                  :string
#  license                      :string
#  npm_author_id                :integer
#  latest_version_date          :datetime
#  deprecated                   :boolean          default(FALSE)
#  note                         :text
#  official                     :boolean          default(FALSE)
#  cli_dependency               :boolean          default(FALSE)
#  hidden                       :boolean          default(FALSE)
#  github_user                  :string
#  github_repo                  :string
#  has_invalid_github_repo      :boolean          default(FALSE)
#  last_month_downloads         :integer
#  is_top_downloaded            :boolean          default(FALSE)
#  is_top_starred               :boolean          default(FALSE)
#  score                        :decimal(5, 2)
#  published_date               :datetime
#  last_seen_in_npm             :datetime
#  is_wip                       :boolean          default(FALSE), not null
#  demo_url                     :string
#  ranking                      :integer
#  latest_addon_version_id      :integer
#  package_info_last_updated_at :datetime
#  repo_info_last_updated_at    :datetime
#  latest_review_id             :integer
#  override_repository_url      :string
#  extends_ember_cli            :boolean
#  extends_ember                :boolean
#  is_monorepo                  :boolean
#  removed_from_npm             :boolean          default(FALSE)
#
# Indexes
#
#  index_addons_on_latest_addon_version_id  (latest_addon_version_id)
#  index_addons_on_latest_review_id         (latest_review_id)
#  index_addons_on_name                     (name) UNIQUE
#  index_addons_on_npm_author_id            (npm_author_id)
#
# Foreign Keys
#
#  fk_rails_...  (latest_addon_version_id => addon_versions.id)
#  fk_rails_...  (latest_review_id => reviews.id)
#

require 'test_helper'

class AddonTest < ActiveSupport::TestCase
  test 'oldest_version returns the earliest addon version' do
    addon = create :addon

    v1 = create :addon_version, addon: addon, version: '1'
    v2 = create :addon_version, addon: addon, version: '2'
    v3 = create :addon_version, addon: addon, version: '3'

    assert_equal v1, addon.oldest_version
  end

  test 'newest_version returns the most recent addon version' do
    addon = create :addon

    v1 = create :addon_version, addon: addon, version: '1'
    v2 = create :addon_version, addon: addon, version: '2'
    v3 = create :addon_version, addon: addon, version: '3'

    assert_equal v3, addon.newest_version
  end

  test 'newest_review returns most recent addon version with a review' do
    addon = create :addon

    v1 = create :addon_version, :with_review, addon: addon
    v2 = create :addon_version, :with_review, addon: addon
    v3 = create :addon_version, addon: addon

    assert_equal v2.review, addon.newest_review
  end

  test 'newest_review returns nil if no addon versions have a review' do
    addon = create :addon

    v1 = create :addon_version, addon: addon
    assert_nil addon.newest_review
  end

  test 'is recently_released if newest version released less than 3 months ago' do
    addon = create :addon, latest_version: '1.2.3'
    create :addon_version, addon: addon, released: 2.months.ago

    assert addon.recently_released?
  end

  test 'not recently_released if newest version released over 3 months ago' do
    addon = create :addon, latest_version: '1.2.3'
    create :addon_version, addon: addon, released: 4.months.ago

    assert !addon.recently_released?
  end

  test 'not recently released if no latest version' do
    addon = build :addon, latest_version: nil

    assert !addon.recently_released?
  end

  test 'recently committed to if penultimate commit date less than 3 months ago' do
    stats = build :github_stats, penultimate_commit_date: 2.months.ago
    addon = build :addon, github_stats: stats

    assert addon.recently_committed_to?
  end

  test 'not recently committed to if no github stats' do
    addon = build :addon, github_stats: nil

    assert !addon.recently_committed_to?
  end

  test 'not recently committed to if no penultimate commit date' do
    stats = build :github_stats, penultimate_commit_date: nil
    addon = build :addon, github_stats: stats

    assert !addon.recently_committed_to?
  end

  test 'not recently committed to if penultimate commit date over 3 months ago' do
    stats = build :github_stats, penultimate_commit_date: 4.months.ago
    addon = build :addon, github_stats: stats

    assert !addon.recently_committed_to?
  end

  test 'query for active addons returns those that are not hidden and not wip' do
    create :addon, hidden: true
    create :addon, is_wip: true

    active = create :addon, hidden: false, is_wip: false
    also_active = create :addon, hidden: nil, is_wip: false

    assert_equal [active, also_active], Addon.active.to_a
  end

  test 'top_scoring returns addons with score above 7' do
    create :addon, score: 1
    create :addon, score: 7

    top = create :addon, score: 8
    also_top = create :addon, score: 10

    assert_equal [top, also_top], Addon.top_scoring.to_a
  end

  test 'top_scoring excludes addons marked as deprecated' do
    top = create(:addon, score: 8)
    top_but_deprecated = create(:addon, score: 10, deprecated: true)

    assert_equal [top], Addon.top_scoring.to_a
  end

  test 'top_n returns the top N addons' do
    create(:addon, score: 8, last_month_downloads: 4)
    create(:addon, score: 9)
    create(:addon, score: 8, last_month_downloads: 100)
    create(:addon, score: 10)
    create(:addon, score: 8, last_month_downloads: 54)
    create(:addon, score: 8, last_month_downloads: 77)

    top_addons = Addon.top_n(5)

    assert_equal 5, top_addons.count, 'returns the request number of addons'
    assert_equal [10, 9, 8, 8, 8], top_addons.map(&:score), 'sorts addons by score'
    assert_equal [100, 77, 54], top_addons.select { |addon| addon.score == 8 }.map(&:last_month_downloads), 'sorts addons with the same score by download count'
  end

  test 'missing_repo_url returns addons without a repository_url set' do
    create :addon, repository_url: ' '
    missing = create :addon, repository_url: nil
    missing_but_a_string = create :addon, repository_url: ''
    create :addon, repository_url: 'http://example.org'

    assert_equal [missing, missing_but_a_string], Addon.missing_repo_url.to_a
  end

  test 'repo_url? scope returns addons with a repository_url set' do
    one = create :addon, repository_url: ' '
    create :addon, repository_url: nil
    create :addon, repository_url: ''
    two = create :addon, repository_url: 'http://example.org'

    assert_equal [one, two], Addon.repo_url?.to_a
  end

  test 'published_to_npm returns addons not removed_from_npm' do
    one = create :addon, removed_from_npm: false
    two = create :addon, removed_from_npm: false
    create :addon, removed_from_npm: true

    assert_equal [one, two], Addon.published_to_npm
  end

  test 'score_to_fixed n = 1' do
    integer_addon = create :addon, score: 9
    round_up_addon = create :addon, score: 8.55
    round_down_addon = create :addon, score: 8.54
    round_up_addon_another_example = create :addon, score: 1.25

    assert_equal('9.0', integer_addon.score_to_fixed(1))
    assert_equal('8.6', round_up_addon.score_to_fixed(1))
    assert_equal('8.5', round_down_addon.score_to_fixed(1))
    assert_equal('1.3', round_up_addon_another_example.score_to_fixed(1))
  end

  test 'score_to_fixed n = 2' do
    integer_addon = create :addon, score: 9
    round_up_addon = create :addon, score: 8.555
    round_down_addon = create :addon, score: 8.554
    already_two_decimals = create :addon, score: 1.25

    assert_equal('9.00', integer_addon.score_to_fixed(2))
    assert_equal('8.56', round_up_addon.score_to_fixed(2))
    assert_equal('8.55', round_down_addon.score_to_fixed(2))
    assert_equal('1.25', already_two_decimals.score_to_fixed(2))
  end

  test 'score_to_fixed n = 0' do
    integer_addon = create :addon, score: 9
    round_up_addon = create :addon, score: 8.55
    round_down_addon = create :addon, score: 8.45
    another_round_down_addon = create :addon, score: 1.25

    assert_equal('9', integer_addon.score_to_fixed(0))
    assert_equal('9', round_up_addon.score_to_fixed(0))
    assert_equal('8', round_down_addon.score_to_fixed(0))
    assert_equal('1', another_round_down_addon.score_to_fixed(0))
  end

  test 'has_tests' do
    addon = create :addon

    assert_nil(addon.has_tests, 'Does not error if latest_review is nil')

    version = create :addon_version, addon: addon, version: '1'
    review = create :review, addon_version: version, has_tests: 5
    addon.latest_review = review

    assert_equal(5, addon.has_tests, 'Delegates has_tests to latest_review')
  end

  test 'has_readme' do
    addon = create :addon

    assert_nil(addon.has_readme, 'Does not error if latest_review is nil')

    version = create :addon_version, addon: addon, version: '1'
    review = create :review, addon_version: version, has_readme: 3
    addon.latest_review = review

    assert_equal(3, addon.has_readme, 'Delegates has_readme to latest_review')
  end

  test 'has_build' do
    addon = create :addon

    assert_nil(addon.has_build, 'Does not error if latest_review is nil')

    version = create :addon_version, addon: addon, version: '1'
    review = create :review, addon_version: version, has_build: 2
    addon.latest_review = review

    assert_equal(2, addon.has_build, 'Delegates has_build to latest_review')
  end

  test 'github_contributors_count' do
    addon = create :addon, :with_github_users, user_count: 9
    assert_equal(9, addon.github_contributors_count, 'Count of contributors is from relationship')

    no_contributors_addon = create :addon
    assert_equal(0, no_contributors_addon.github_contributors_count, 'Count works for no contributors')
  end

  test '.reviewed scope returns only addons which have been reviewed' do
    create_list :addon, 10
    reviewed_addon = create(:addon, :with_reviewed_version)

    assert_equal [reviewed_addon], Addon.reviewed.to_a, 'addons without reviews are excluded'
  end

  test '#reviewed? returns true when addon has at least one review' do
    addon = create(:addon, :with_reviewed_version)

    assert_equal true, addon.reviewed?
  end

  test '#reviewed? returns false when addon does not have any reviews' do
    addon = create(:addon, :with_unreviewed_version)

    assert_equal false, addon.reviewed?
  end
end
