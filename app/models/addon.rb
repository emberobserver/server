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
#  author_id               :integer
#  latest_version_date     :datetime
#  deprecated              :boolean          default("false")
#  note                    :text
#  official                :boolean          default("false")
#  cli_dependency          :boolean          default("false")
#  hidden                  :boolean          default("false")
#  github_user             :string
#  github_repo             :string
#  has_invalid_github_repo :boolean          default("false")
#

class Addon < ActiveRecord::Base
  has_many :addon_versions, -> { order(released: :asc) }
  has_many :addon_maintainers
  has_many :addon_npm_keywords

  has_many :category_addons
  has_many :categories, through: :category_addons
  belongs_to :author, class_name: 'NpmUser'
  has_many :npm_keywords, through: :addon_npm_keywords
  has_many :maintainers, through: :addon_maintainers, source: :npm_user

  has_many :downloads, foreign_key: 'addon_id', class: AddonDownload
  has_one :github_stats

  has_many :addon_github_contributors
  has_many :github_contributors, through: :addon_github_contributors, source: :github_user

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
end
