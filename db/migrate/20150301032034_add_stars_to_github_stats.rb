class AddStarsToGithubStats < ActiveRecord::Migration
  def change
    add_column :github_stats, :stars, :integer
  end
end
