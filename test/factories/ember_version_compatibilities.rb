# frozen_string_literal: true

# == Schema Information
#
# Table name: ember_version_compatibilities
#
#  id             :integer          not null, primary key
#  test_result_id :integer
#  ember_version  :string
#  compatible     :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_ember_version_compatibilities_on_test_result_id  (test_result_id)
#
# Foreign Keys
#
#  fk_rails_...  (test_result_id => test_results.id)
#

FactoryGirl.define do
  factory :version_compatibility do
    ember_version '1.0.0'
    compatible true
  end
end
