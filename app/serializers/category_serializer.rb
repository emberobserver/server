class CategorySerializer < ApplicationSerializer
  attributes :id, :name, :description, :parent_id
  has_many :addons, include: false
  has_many :subcategories, include: false
end
