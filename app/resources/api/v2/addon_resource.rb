# frozen_string_literal: true

# rubocop:disable all Metrics/LineLength Naming/PredicateName
class API::V2::AddonResource < JSONAPI::Resource
  attributes :name,
             :latest_version_date,
             :description, :is_deprecated,
             :is_official, :is_cli_dependency,
             :is_hidden,
             :score, :is_wip, :is_fully_loaded,
             :ranking, :published_date,
             :repository_url,
             :license, :note,
             :has_invalid_github_repo,
             :last_month_downloads, :is_top_downloaded, :is_top_starred,
             :demo_url, :updated_at,
             :has_been_reviewed,
             :override_repository_url,
             :extends_ember, :extends_ember_cli,
             :is_monorepo

  has_many :maintainers, class_name: 'Maintainer'
  has_many :versions, class_name: 'Version', relation_name: 'addon_versions'
  has_many :keywords, class_name: 'Keyword', relation_name: 'npm_keywords'
  has_many :github_users
  has_many :categories
  has_one :github_stats
  has_one :readme
  has_one :latest_addon_version, class_name: 'Version', relation_name: 'latest_addon_version'
  has_one :latest_review, class_name: 'Review', relation_name: 'latest_review'

  paginator :offset

  DEFAULT_PAGE_SIZE = 977

  filter :name
  filter :id

  REQUIRE_ADMIN = ->(values, context) {
    if values.include?('true') && context[:current_user].nil?
      raise Forbidden
    end
    values
  }

  filter :in_category, apply: ->(_records, category_id, _options) {
    Category.find(category_id.first).addons
  }

  filter :top, apply: ->(records, _value, _options) {
    records.where('ranking is not null')
  }

  filter :hidden, verify: REQUIRE_ADMIN, default: 'false'

  filter :removed_from_npm, verify: REQUIRE_ADMIN, default: 'false'

  filter :is_wip

  filter :not_categorized, verify: REQUIRE_ADMIN, apply: ->(records, _value, _options) {
    records.not_hidden.includes(:categories).where(categories: { id: nil })
  }

  filter :not_reviewed, verify: REQUIRE_ADMIN, apply: ->(records, _value, _options) {
    records.needs_review
  }

  filter :missing_repo_url, apply: ->(records, _value, _options) do
    records.not_hidden.missing_repo_url
  end

  filter :invalid_repo_url, verify: REQUIRE_ADMIN, apply: ->(records, _value, _options) do
    records.not_hidden.invalid_repo_url
  end

  filter :needs_re_review, verify: REQUIRE_ADMIN, apply: ->(records, _value, _options) {
    records.needing_rereview
  }

  filter :has_repo_url, apply: ->(records, _value, _options) do
    records.repo_url?
  end

  filter :code_search, apply: ->(records, _value, _options) {
    records.not_hidden
  }

  filter :recently_reviewed, apply: ->(_records, _value, options) {
    limit = options[:paginator] && options[:paginator].limit != DEFAULT_PAGE_SIZE ? options[:paginator].limit : 10
    Addon.joins(:addon_versions).where('addon_versions.id IN (?)', Review.order('created_at DESC').limit(limit).select('addon_version_id')).distinct
  }

  def self.find(filters, options = {})
    has_specified_filter = !(filters.keys.sort == [:hidden, :removed_from_npm] && filters[:hidden] == %w[false] && filters[:removed_from_npm] == %w[false])
    has_valid_limit = options[:paginator] ? options[:paginator].limit <= 100 : false
    has_sort = options[:sort_criteria] ? ![:sort_criteria].empty? : false
    raise Forbidden unless has_specified_filter || (has_valid_limit && has_sort)
    super
  end

  def is_deprecated
    @model.deprecated
  end

  def is_deprecated=(value)
    @model.deprecated = value
  end

  def is_official
    @model.official
  end

  def is_official=(value)
    @model.official = value
  end

  def is_cli_dependency
    @model.cli_dependency
  end

  def is_cli_dependency=(value)
    @model.cli_dependency = value
  end

  def has_been_reviewed
    !!@model.latest_review_id
  end

  def is_hidden
    @model.hidden
  end

  def is_hidden=(value)
    @model.hidden = value
  end

  def is_fully_loaded
    true
  end

  def score
    @model.score_to_fixed(1)
  end

  UPDATABLE_ATTRIBUTES = %i[
    is_deprecated is_official is_cli_dependency
    is_hidden is_wip note has_invalid_github_repo
    override_repository_url extends_ember
    extends_ember_cli is_monorepo
  ].freeze

  UPDATABLE_RELATIONSHIPS = [
    :categories,
    :latest_review
  ].freeze

  def self.updatable_fields(context)
    return [] unless context[:current_user]
    UPDATABLE_ATTRIBUTES + UPDATABLE_RELATIONSHIPS
  end

  def self.creatable_fields(_context)
    []
  end
end
# rubocop:enable all Metrics/LineLength Naming/PredicateName
