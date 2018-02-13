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
# Indexes
#
#  index_github_stats_on_addon_id  (addon_id)
#
# Foreign Keys
#
#  fk_rails_...  (addon_id => addons.id)
#

FactoryGirl.define do
  factory :github_stats do
  end
end
