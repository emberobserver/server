# frozen_string_literal: true

# == Schema Information
#
# Table name: size_calculation_results
#
#  id               :integer          not null, primary key
#  addon_version_id :integer
#  succeeded        :boolean
#  error_message    :text
#  output           :text
#  build_server_id  :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_size_calculation_results_on_addon_version_id  (addon_version_id)
#  index_size_calculation_results_on_build_server_id   (build_server_id)
#
# Foreign Keys
#
#  fk_rails_...  (addon_version_id => addon_versions.id)
#  fk_rails_...  (build_server_id => build_servers.id)
#

FactoryBot.define do
  factory :size_calculation_result do
    association :addon_version
    association :build_server
  end
end
