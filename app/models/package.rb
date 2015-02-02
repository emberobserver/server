# == Schema Information
#
# Table name: packages
#
#  id             :integer          not null, primary key
#  name           :string
#  npmjs_url      :string
#  repository_url :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  latest_version :string
#  description    :string
#

class Package < ActiveRecord::Base
  has_many :reviews

  has_many :category_packages
  has_many :categories, through: :category_packages
  belongs_to :author, class_name: 'NpmUser'
  has_and_belongs_to_many :npm_keywords, join_table: 'package_npm_keywords'
  has_and_belongs_to_many :maintainers, class_name: 'NpmUser', join_table: 'package_maintainers'
end
