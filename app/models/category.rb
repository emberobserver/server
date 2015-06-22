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

class Category < ActiveRecord::Base
  has_many :category_addons
  has_many :addons, through: :category_addons

  has_many :subcategories, class_name: 'Category', foreign_key: 'parent_id'
  belongs_to :parent_category, class_name: 'Category', foreign_key: 'parent_id'

  validates :name, presence: true
  validates :position, presence: true, uniqueness: { scope: 'parent_id' }

  before_validation :transform_position

  private

  def transform_position
    return if self.position && self.position != -1
    last_position = Category.where(parent_id: self.parent_id).order('position desc').first.position
    self.position = last_position + 1
  end
end
