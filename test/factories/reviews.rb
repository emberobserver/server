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

FactoryGirl.define do
  factory :review do
    has_tests true
    has_readme true
    is_more_than_empty_addon true
    is_open_source true
    has_build true
  end
end
