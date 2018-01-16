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

class Review < ApplicationRecord
  belongs_to :addon_version

  before_create :set_addon_name

  def addon
    addon_version.addon
  end

  def version_id=(value)
    self.addon_version_id = value
  end

  private

  def set_addon_name
    self.addon_name = addon_version.addon_name
  end
end
