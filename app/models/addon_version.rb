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

class AddonVersion < ActiveRecord::Base
	belongs_to :addon
	has_one :review, -> { order 'created_at DESC' }
	has_many :all_dependencies, foreign_key: 'addon_version_id', class_name: 'AddonVersionDependency'
	has_many :compatible_versions, foreign_key: 'addon_version_id', class_name: 'AddonVersionCompatibility'

  before_create :set_addon_name

	def dependencies
		all_dependencies.where(dependency_type: 'dependencies')
	end

	def dev_dependencies
		all_dependencies.where(dependency_type: 'devDependencies')
	end

  def set_addon_name
    self.addon_name = addon.name
  end
end
