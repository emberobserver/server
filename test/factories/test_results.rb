# frozen_string_literal: true

# == Schema Information
#
# Table name: test_results
#
#  id               :integer          not null, primary key
#  addon_version_id :integer
#  succeeded        :boolean
#  status_message   :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  canary           :boolean          default(FALSE), not null
#  build_server_id  :integer
#  semver_string    :string
#  output           :text
#

FactoryGirl.define do
  factory :test_result do
    association :addon_version
    association :build_server
  end
end
