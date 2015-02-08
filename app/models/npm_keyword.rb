# == Schema Information
#
# Table name: npm_keywords
#
#  id         :integer          not null, primary key
#  keyword    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class NpmKeyword < ActiveRecord::Base
	has_and_belongs_to_many :addons, join_table: 'addon_npm_keywords'
end
