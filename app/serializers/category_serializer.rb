# == Schema Information
#
# Table name: categories
#
#  id          :integer          not null, primary key
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#  parent_id   :integer
#  position    :integer
#

class CategorySerializer < ApplicationSerializer
  attributes :id, :name, :description, :parent_id, :position
  has_many :addons, include: false
  has_many :subcategories, include: false
end
