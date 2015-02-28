class AddonGithubContributor < ActiveRecord::Base
	belongs_to :addon
	belongs_to :github_user
end
