class CategorySerializer < ApplicationSerializer
  attributes :id, :name, :description, :parent_id, :position
  has_many :addons, include: false
  has_many :subcategories, include: false
end
