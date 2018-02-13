# frozen_string_literal: true

# == Schema Information
#
# Table name: github_stats
#
#  id                      :integer          not null, primary key
#  addon_id                :integer
#  open_issues             :integer
#  contributors            :integer
#  commits                 :integer
#  forks                   :integer
#  first_commit_date       :datetime
#  first_commit_sha        :string
#  latest_commit_date      :datetime
#  latest_commit_sha       :string
#  stars                   :integer
#  penultimate_commit_date :datetime
#  penultimate_commit_sha  :string
#  repo_created_date       :datetime
#

class GithubStats < ApplicationRecord
  belongs_to :addon

  def addon_recently_committed_to?
    return false unless penultimate_commit_date
    penultimate_commit_date > 3.months.ago
  end
end
