class Package < ActiveRecord::Base
  has_many :reviews

  has_many :category_packages
  has_many :categories, through: :category_packages
end
