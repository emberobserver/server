# frozen_string_literal: true

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
# Indexes
#
#  index_reviews_on_addon_version_id  (addon_version_id)
#

FactoryBot.define do
  factory :review do
  end
end
