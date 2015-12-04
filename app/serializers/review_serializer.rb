# == Schema Information
#
# Table name: reviews
#
#  id                       :integer          not null, primary key
#  has_tests                :integer
#  has_readme               :integer
#  is_more_than_empty_addon :integer
#  review                   :text
#  addon_version_id         :integer          not null
#  created_at               :datetime
#  updated_at               :datetime
#  is_open_source           :integer
#  has_build                :integer
#  addon_name               :string
#

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
