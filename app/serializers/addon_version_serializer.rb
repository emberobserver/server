# == Schema Information
#
# Table name: addon_versions
#
#  id                :integer          not null, primary key
#  addon_id          :integer
#  version           :string
#  released          :datetime
#  addon_name        :string
#  ember_cli_version :string
#

class AddonVersionSerializer < ApplicationSerializer
	attributes :id, :version, :released, :addon_id, :ember_cli_version
  has_one :review
	has_one :test_result

	def test_result
		object.latest_test_result
	end
end
