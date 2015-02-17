# == Schema Information
#
# Table name: addon_versions
#
#  id         :integer          not null, primary key
#  addon_id   :integer
#  version    :string
#  released   :datetime
#  addon_name :string
#

class AddonVersion < ActiveRecord::Base
	belongs_to :addon
	has_one :review

  before_create :set_addon_name

  def set_addon_name
    self.addon_name = addon.name
  end
end
