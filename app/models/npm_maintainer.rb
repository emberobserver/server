# == Schema Information
#
# Table name: npm_maintainers
#
#  id         :integer          not null, primary key
#  name       :string
#  email      :string
#  gravatar   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class NpmMaintainer < ActiveRecord::Base
  has_many :addon_maintainers
  has_many :addons, through: :addon_maintainers
end
