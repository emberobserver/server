class SimpleAddonSerializer < ApplicationSerializer
  attributes :id, :name,
             :latest_version_date,
             :latest_reviewed_version_date,
             :description, :is_deprecated,
             :is_official, :is_cli_dependency,
             :is_hidden,
             :score, :is_wip, :is_fully_loaded

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

  def latest_reviewed_version_date
    object.newest_review ? object.newest_review.addon_version.released : nil
  end

  def is_fully_loaded
    false
  end

end
