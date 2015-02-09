class ReviewSerializer < ApplicationSerializer
	attributes :id, :created_at, :has_tests, :has_readme,
             :is_more_than_empty_addon, :review, :is_open_source,
             :uses_only_public_apis, :has_build, :version_id

  def version_id
    object.addon_version_id
  end

end
