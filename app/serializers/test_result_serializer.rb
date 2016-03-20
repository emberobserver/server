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
#

class TestResultSerializer < ApplicationSerializer
  attributes :id, :succeeded, :status_message
  has_many :ember_version_compatibilities
end
