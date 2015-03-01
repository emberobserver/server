class AddPenultimateCommitFields < ActiveRecord::Migration
  def change
    add_column :github_stats, :penultimate_commit_date, :datetime
    add_column :github_stats, :penultimate_commit_sha, :string
  end
end
