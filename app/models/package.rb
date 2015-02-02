# == Schema Information
#
# Table name: packages
#
#  id             :integer          not null, primary key
#  name           :string
#  npmjs_url      :string
#  github_url     :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  latest_version :string
#  description    :string
#

class Package < ActiveRecord::Base
  has_many :reviews

  has_many :category_packages
  has_many :categories, through: :category_packages
end
