# == Schema Information
#
# Table name: npm_users
#
#  id         :integer          not null, primary key
#  name       :string
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  gravatar   :string
#

class NpmUser < ActiveRecord::Base
  has_many :addon_maintainers
  has_many :addons, through: :addon_maintainers
end
