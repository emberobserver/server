class API::V2::AddonResource < JSONAPI::Resource
  attributes :name,
             :latest_version_date,
             :description, :is_deprecated,
             :is_official, :is_cli_dependency,
             :is_hidden,
             :score, :is_wip, :is_fully_loaded,
             :ranking, :published_date,
             :rendered_note, :repository_url,
             :license, :note,
             :is_new_addon, :has_invalid_github_repo,
             :open_issues, :forks, :contributors,
             :first_commit_date, :latest_commit_date,
             :last_month_downloads, :is_top_downloaded, :is_top_starred,
             :stars, :committed_to_recently, :demo_url

  has_many :maintainers, class_name: 'Maintainer'
  has_many :versions, class_name: 'Version', relation_name: 'addon_versions'
  has_many :keywords, class_name: 'Keyword', relation_name: 'npm_keywords'
  has_many :reviews
  has_many :categories
  # has_one :readme

  # Need: has_one :latest_review

  paginator :offset
  filter :name

  filter :in_category, apply: ->(records, category_id, _options) {
    Category.where(id: category_id).first.addons
  }

  filter :top, apply: ->(records, value, _options) {
    records.where('ranking is not null')
  }

  filter :hidden, default: 'false'

  filter :recently_reviewed, apply: ->(records, value, _options) {
    limit = _options[:paginator] ? _options[:paginator].limit : 10
    Addon.joins(:addon_versions).where("addon_versions.id IN (?)", Review.order('created_at DESC').limit(limit).select('addon_version_id'))
  }

  def is_deprecated
    @model.deprecated
  end

  def is_official
    @model.official
  end

  def is_cli_dependency
    @model.cli_dependency
  end

  def is_hidden
    @model.hidden
  end

  def is_fully_loaded
    true
  end

  def is_new_addon
    @model.oldest_version && @model.oldest_version.released > 2.weeks.ago
  end

  def open_issues
    @model.github_stats ? @model.github_stats.open_issues : nil
  end

  def forks
    @model.github_stats ? @model.github_stats.forks : nil
  end

  def first_commit_date
    @model.github_stats ? @model.github_stats.first_commit_date : nil
  end

  def latest_commit_date
    @model.github_stats ? @model.github_stats.latest_commit_date : nil
  end

  def committed_to_recently
    @model.recently_committed_to?
  end

  def contributors
    @model.github_contributors.map do |contributor|
      { name: contributor.login, avatar_url: contributor.avatar_url }
    end
  end

  def stars
    @model.github_stats ? @model.github_stats.stars : nil
  end

  #TODO: Make github stats a relationship
  #TODO: put oldest release date on model
  #TODO: make contributors a relationship
end
