# == Schema Information
#
# Table name: npm_keywords
#
#  id         :integer          not null, primary key
#  keyword    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class NpmKeywordSerializer < ApplicationSerializer
  attributes :id, :keyword
  has_many :addons, include: false
end
