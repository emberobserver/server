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
  has_and_belongs_to_many :addons, join_table: 'addon_maintainers'
end
