class CategorySerializer < ApplicationSerializer
  attributes :id, :name, :description
  has_many :addons, embed_in_root: false
end
