# == Schema Information
#
# Table name: addon_versions
#
#  id       :integer          not null, primary key
#  addon_id :integer
#  version  :string
#  released :datetime
#

class AddonVersion < ActiveRecord::Base
	belongs_to :addon
	has_one :review
end
