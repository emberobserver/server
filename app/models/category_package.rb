class CategoryPackage < ActiveRecord::Base
  belongs_to :category
  belongs_to :package
end
