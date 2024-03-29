# frozen_string_literal: true

# == Schema Information
#
# Table name: test_results
#
#  id                :integer          not null, primary key
#  addon_version_id  :integer
#  succeeded         :boolean
#  status_message    :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  build_server_id   :integer
#  semver_string     :string
#  output            :text
#  output_format     :string           default("text"), not null
#  ember_try_results :jsonb
#  build_type        :string
#
# Indexes
#
#  index_test_results_on_addon_version_id  (addon_version_id)
#  index_test_results_on_build_server_id   (build_server_id)
#
# Foreign Keys
#
#  fk_rails_...  (addon_version_id => addon_versions.id)
#  fk_rails_...  (build_server_id => build_servers.id)
#

FactoryBot.define do
  factory :test_result do
    association :addon_version
    association :build_server

    build_type { 'ember_version_compatibility' }

    trait :canary do
      build_type { 'canary' }
    end
  end
end
