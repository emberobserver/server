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
#  rendered_note                :text
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

# TODO: drop `rendered_note` once entirely on API v2
class Addon < ApplicationRecord
  has_many :addon_versions, -> { order(released: :asc) }
  belongs_to :latest_addon_version, class_name: 'AddonVersion', optional: true
  has_many :reviews, through: :addon_versions
  belongs_to :latest_review, class_name: 'Review', optional: true
  has_many :addon_maintainers
  has_many :addon_npm_keywords

  has_many :category_addons
  has_many :categories, through: :category_addons
  belongs_to :author, class_name: 'NpmAuthor', foreign_key: :npm_author_id, optional: true
  has_many :npm_keywords, through: :addon_npm_keywords
  has_many :maintainers, through: :addon_maintainers, source: :npm_maintainer

  has_many :downloads, foreign_key: 'addon_id', class_name: 'AddonDownload'
  has_one :github_stats

  has_many :addon_github_contributors

  # TODO: Remove github_contributors relationship
  has_many :github_contributors, through: :addon_github_contributors, source: :github_user
  has_many :github_users, through: :addon_github_contributors

  has_one :readme, dependent: :destroy

  has_many :test_results, through: :addon_versions

  delegate :has_tests, :has_readme, :has_build, to: :latest_review, allow_nil: true
  delegate :count, to: :github_users, prefix: :github_contributors

  def oldest_version
    addon_versions.first
  end

  def newest_version
    addon_versions.last
  end

  def newest_review
    reviews.order('created_at DESC').first
  end

  def recently_released?
    return false unless latest_version
    newest_version.released > 3.months.ago
  end

  def recently_committed_to?
    return false unless github_stats
    return false unless github_stats.penultimate_commit_date
    github_stats.penultimate_commit_date > 3.months.ago
  end

  def score_to_fixed(n = 0)
    format("%.#{n}f", score) if score
  end

  def valid_github_repo?
    !has_invalid_github_repo?
  end

  def self.active
    not_hidden.where('(is_wip is null or is_wip != true)')
  end

  def self.not_hidden
    published_to_npm.where('hidden is null or hidden != true')
  end

  def self.published_to_npm
    where('removed_from_npm = false')
  end

  def self.needing_rereview
    active.where('name in (?)', Review.select(:addon_name)).joins(:latest_addon_version).where('addon_versions.id NOT IN (?)', Review.select(:addon_version_id))
  end

  def self.top_scoring
    where('score > ?', 7).where(deprecated: false)
  end

  def self.ranked
    where('ranking is not null')
  end

  def self.missing_repo_url
    where('repository_url is null or repository_url = ?', '')
  end

  def self.repo_url?
    where('repository_url is not null and repository_url != ?', '')
  end

  def self.invalid_repo_url
    where(has_invalid_github_repo: true)
  end

  def self.top_n(n)
    Addon.active.top_scoring.order('score desc').order('last_month_downloads desc').limit(n)
  end

  def self.needs_review
    active.where('latest_review_id is null')
  end
end
