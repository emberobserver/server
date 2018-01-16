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

class Category < ApplicationRecord
  has_many :category_addons
  has_many :addons, through: :category_addons

  has_many :subcategories, class_name: 'Category', foreign_key: 'parent_id'
  belongs_to :parent_category, class_name: 'Category', foreign_key: 'parent_id', optional: true

  validates :name, presence: true
  validates :position, presence: true, uniqueness: { scope: 'parent_id' }
  validate :cannot_be_own_parent

  before_validation :transform_position

  private

  def cannot_be_own_parent
    if id && id == parent_id
      errors.add(:parent_id, "Category cannot have itself as its parent")
    end
  end

  def transform_position
    return if self.position && self.position != -1
    last_sibling_category = Category.where(parent_id: self.parent_id).order('position desc').first
    if last_sibling_category
      self.position = last_sibling_category.position + 1
    else
      self.position = 1
    end
  end
end
