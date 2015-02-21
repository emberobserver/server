class AddonSerializer < ApplicationSerializer
  attributes :id, :name, :repository_url,
             :latest_version_date,
             :description, :license, :is_deprecated,
             :note, :is_official, :is_cli_dependency,
             :is_hidden, :is_new_addon

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
end
