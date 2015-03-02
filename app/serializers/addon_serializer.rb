class AddonSerializer < ApplicationSerializer
  attributes :id, :name, :rendered_note, :repository_url,
             :latest_version_date,
             :description, :license, :is_deprecated,
             :note, :is_official, :is_cli_dependency,
             :is_hidden, :is_new_addon, :has_invalid_github_repo,
             :open_issues, :forks, :contributors,
             :first_commit_date, :latest_commit_date,
             :last_month_downloads, :is_top_downloaded, :is_top_starred,
             :score, :stars

  has_many :maintainers

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
    object.oldest_version.released > 2.weeks.ago
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

  def contributors
    object.github_contributors.map do |contributor|
      { name: contributor.login, avatar_url: contributor.avatar_url }
    end
  end

  def stars
    object.github_stats ? object.github_stats.stars : nil
  end
end
