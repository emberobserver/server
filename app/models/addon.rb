# == Schema Information
#
# Table name: addons
#
#  id                  :integer          not null, primary key
#  name                :string
#  repository_url      :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  latest_version      :string
#  description         :string
#  license             :string
#  author_id           :integer
#  latest_version_date :datetime
#

class Addon < ActiveRecord::Base
  has_many :addon_versions

  has_many :category_addons
  has_many :categories, through: :category_addons
  belongs_to :author, class_name: 'NpmUser'
  has_and_belongs_to_many :npm_keywords, join_table: 'addon_npm_keywords'
  has_and_belongs_to_many :maintainers, class_name: 'NpmUser', join_table: 'addon_maintainers'
end
