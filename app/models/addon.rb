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
#

class Addon < ActiveRecord::Base
  has_many :addon_versions, -> { order(released: :asc) }
  has_many :reviews, through: :addon_versions
  has_many :addon_maintainers
  has_many :addon_npm_keywords

  has_many :category_addons
  has_many :categories, through: :category_addons
  belongs_to :author, class_name: 'NpmAuthor', foreign_key: :npm_author_id
  has_many :npm_keywords, through: :addon_npm_keywords
  has_many :maintainers, through: :addon_maintainers, source: :npm_maintainer

  has_many :downloads, foreign_key: 'addon_id', class_name: 'AddonDownload'
  has_one :github_stats

  has_many :addon_github_contributors
  has_many :github_contributors, through: :addon_github_contributors, source: :github_user

  has_one :readme, dependent: :destroy

  def oldest_version
    addon_versions.first
  end

  def newest_version
    addon_versions.last
  end

  def newest_review
    newest_version_with_review = addon_versions.reverse.find { |version| !version.review.nil? }
    newest_version_with_review ? newest_version_with_review.review : nil
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

  def self.active
    where('(hidden is null or hidden != true) and (is_wip is null or is_wip != true)')
  end

  def self.top_scoring
    where('score > ?', 7)
  end
end
