# == Schema Information
#
# Table name: addon_version_compatibilities
#
#  id               :integer          not null, primary key
#  addon_version_id :integer
#  package          :string
#  version          :string
#

class AddonVersionCompatibility < ApplicationRecord
  belongs_to :addon_version
end
