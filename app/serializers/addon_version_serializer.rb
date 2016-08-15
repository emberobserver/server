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
  has_many :test_results
end
