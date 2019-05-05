# == Schema Information
#
# Table name: size_calculation_results
#
#  id               :integer          not null, primary key
#  addon_version_id :integer
#  succeeded        :boolean
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

class SizeCalculationResult < ApplicationRecord
  belongs_to :addon_version
  belongs_to :build_server
end
