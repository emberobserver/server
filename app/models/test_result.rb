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
#

class TestResult < ActiveRecord::Base
  belongs_to :addon_version
  belongs_to :build_server
  has_many :ember_version_compatibilities
end
