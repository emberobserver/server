# == Schema Information
#
# Table name: npm_users
#
#  id         :integer          not null, primary key
#  name       :string
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class NpmUser < ActiveRecord::Base
	
end
