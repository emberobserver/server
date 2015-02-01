class Category < ActiveRecord::Base
  has_many :category_packages
  has_many :packages, through: :category_packages
end
