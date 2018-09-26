# frozen_string_literal: true

# == Schema Information
#
# Table name: pending_size_calculations
#
#  id                :integer          not null, primary key
#  addon_version_id  :integer
#  build_assigned_at :datetime
#  build_server_id   :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_pending_size_calculations_on_addon_version_id  (addon_version_id)
#  index_pending_size_calculations_on_build_server_id   (build_server_id)
#
# Foreign Keys
#
#  fk_rails_...  (addon_version_id => addon_versions.id)
#  fk_rails_...  (build_server_id => build_servers.id)
#

FactoryBot.define do
  factory :pending_size_calculation do
    association :addon_version, factory: %i[addon_version basic]
  end
end
