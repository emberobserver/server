# == Schema Information
#
# Table name: category_packages
#
#  id          :integer          not null, primary key
#  category_id :integer
#  package_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class CategoryPackage < ActiveRecord::Base
  belongs_to :category
  belongs_to :package
end
