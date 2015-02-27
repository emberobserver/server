# == Schema Information
#
# Table name: addons
#
#  id                      :integer          not null, primary key
#  name                    :string
#  repository_url          :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  latest_version          :string
#  description             :string
#  license                 :string
#  author_id               :integer
#  latest_version_date     :datetime
#  deprecated              :boolean          default("false")
#  note                    :text
#  official                :boolean          default("false")
#  cli_dependency          :boolean          default("false")
#  hidden                  :boolean          default("false")
#  github_user             :string
#  github_repo             :string
#  has_invalid_github_repo :boolean          default("false")
#

class Addon < ActiveRecord::Base
  has_many :addon_versions, -> { order(released: :asc) }
  has_many :addon_maintainers
  has_many :addon_npm_keywords

  has_many :category_addons
  has_many :categories, through: :category_addons
  belongs_to :author, class_name: 'NpmUser'
  has_many :npm_keywords, through: :addon_npm_keywords
  has_many :maintainers, through: :addon_maintainers, source: :npm_user

  has_many :downloads, foreign_key: 'addon_id', class: AddonDownload
  has_one :github_stats

  def oldest_version
    addon_versions.first
  end
end
