# == Schema Information
#
# Table name: categories
#
#  id          :integer          not null, primary key
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#

class Category < ActiveRecord::Base
  has_many :category_addons
  has_many :addons, through: :category_addons

  has_many :subcategories, class_name: 'Category', foreign_key: 'parent_id'
  belongs_to :parent_category, class_name: 'Category', foreign_key: 'parent_id'
end
