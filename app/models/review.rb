# == Schema Information
#
# Table name: reviews
#
#  id                        :integer          not null, primary key
#  has_tests                 :integer
#  has_readme                :integer
#  updated_recently          :integer
#  more_than_a_shell         :integer
#  substantive_functionality :integer
#  review                    :text
#  addon_version_id          :integer          not null
#  created_at                :datetime
#  updated_at                :datetime
#

class Review < ActiveRecord::Base
	belongs_to :addon_version
end
