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
#  is_wip                  :boolean          default(FALSE), not null
#  demo_url                :string
#  ranking                 :integer
#  latest_addon_version_id :integer
#

class AddonSerializer < SimpleAddonSerializer
  attributes :rendered_note, :repository_url,
             :license, :note,
             :is_new_addon, :has_invalid_github_repo,
             :open_issues, :forks, :contributors,
             :first_commit_date, :latest_commit_date,
             :last_month_downloads, :is_top_downloaded, :is_top_starred,
             :stars, :committed_to_recently, :demo_url

  has_many :maintainers
  has_one :readme

  def is_fully_loaded
    true
  end

  def is_deprecated
    object.deprecated
  end

  def is_official
    object.official
  end

  def is_cli_dependency
    object.cli_dependency
  end

  def is_hidden
    object.hidden
  end

  def is_new_addon
    object.oldest_version && object.oldest_version.released > 2.weeks.ago
  end

  def open_issues
    object.github_stats ? object.github_stats.open_issues : nil
  end

  def forks
    object.github_stats ? object.github_stats.forks : nil
  end

  def first_commit_date
    object.github_stats ? object.github_stats.first_commit_date : nil
  end

  def latest_commit_date
    object.github_stats ? object.github_stats.latest_commit_date : nil
  end

  def committed_to_recently
    object.recently_committed_to?
  end

  def contributors
    object.github_contributors.map do |contributor|
      { name: contributor.login, avatar_url: contributor.avatar_url }
    end
  end

  def stars
    object.github_stats ? object.github_stats.stars : nil
  end
end
