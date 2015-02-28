class GithubUser < ActiveRecord::Base
	has_many :addon_github_contributors
	has_many :addons, through: :addon_github_contributors
end
