# == Schema Information
#
# Table name: categories
#
#  id          :integer          not null, primary key
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#

class Category < ActiveRecord::Base
  has_many :category_packages
  has_many :packages, through: :category_packages
end
