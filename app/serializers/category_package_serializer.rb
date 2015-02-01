class CategoryPackageSerializer < ActiveModel::Serializer
  attributes :id
  has_one :category
  has_one :package
end
