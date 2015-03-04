class AddRepoCreatedDateToGithubStats < ActiveRecord::Migration
  def change
    add_column :github_stats, :repo_created_date, :datetime
  end
end
