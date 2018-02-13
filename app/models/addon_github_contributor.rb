# frozen_string_literal: true

# == Schema Information
#
# Table name: addon_github_contributors
#
#  id             :integer          not null, primary key
#  addon_id       :integer
#  github_user_id :integer
#
# Indexes
#
#  index_addon_github_contributors_on_addon_id        (addon_id)
#  index_addon_github_contributors_on_github_user_id  (github_user_id)
#

class AddonGithubContributor < ApplicationRecord
  belongs_to :addon
  belongs_to :github_user
end
