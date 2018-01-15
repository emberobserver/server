# == Schema Information
#
# Table name: github_users
#
#  id         :integer          not null, primary key
#  login      :string
#  avatar_url :string
#

class GithubUser < ApplicationRecord
  has_many :addon_github_contributors
  has_many :addons, through: :addon_github_contributors
end
