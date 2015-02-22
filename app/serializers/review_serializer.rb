class ReviewSerializer < ApplicationSerializer
	attributes :id, :created_at, :has_tests, :has_readme,
             :is_more_than_empty_addon, :review, :is_open_source,
             :has_build, :version_id, :addon_id

  def version_id
    object.addon_version_id
  end

  def addon_id
    object.addon_version.addon_id
  end

end
