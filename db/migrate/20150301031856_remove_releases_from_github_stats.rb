class RemoveReleasesFromGithubStats < ActiveRecord::Migration
  def change
    remove_column :github_stats, :releases
  end
end
