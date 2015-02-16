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
#  uses_only_public_apis    :integer
#  has_build                :integer
#

class Review < ActiveRecord::Base
	belongs_to :addon_version


  before_create :set_addon_name

  def set_addon_name
    self.addon_name = addon_version.addon_name
  end
end
