class CategorySerializer < ApplicationSerializer
  attributes :id, :name, :description
  has_many :packages
end
