class CategoryPackageSerializer < ApplicationSerializer
  attributes :id
  has_one :category
  has_one :package
end
