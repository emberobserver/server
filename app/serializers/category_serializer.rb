class CategorySerializer < ApplicationSerializer
  attributes :id, :name, :description
  has_many :addons, include: false
end
