# == Schema Information
#
# Table name: addon_version_dependencies
#
#  id               :integer          not null, primary key
#  package          :string
#  version          :string
#  dependency_type  :string
#  addon_version_id :integer
#

class AddonVersionDependency < ActiveRecord::Base
  belongs_to :addon_version
end
