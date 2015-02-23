class CategorySerializer < ApplicationSerializer
  attributes :id, :name, :description, :parent_id, :categories
  has_many :addons, include: false

  def categories
    object.subcategories.map(&:id)
  end
end
