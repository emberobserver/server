# == Schema Information
#
# Table name: addon_github_contributors
#
#  id             :integer          not null, primary key
#  addon_id       :integer
#  github_user_id :integer
#

class AddonGithubContributor < ActiveRecord::Base
  belongs_to :addon
  belongs_to :github_user
end
